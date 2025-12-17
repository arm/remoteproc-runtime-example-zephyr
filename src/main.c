#include <errno.h>
#include <string.h>

#include <zephyr/kernel.h>
#include <zephyr/sys/atomic.h>
#include <zephyr/device.h>
#include <zephyr/drivers/ipm.h>
#include <zephyr/logging/log.h>
#include <zephyr/sys/__assert.h>
#include <zephyr/sys/printk.h>
#include <zephyr/sys/util.h>

#include <openamp/open_amp.h>
#include <metal/sys.h>
#include <metal/io.h>
#include <resource_table.h>
#include <addr_translation.h>
#include <openamp/rpmsg.h>

LOG_MODULE_REGISTER(rpmsg_hello, LOG_LEVEL_INF);

#define RPMSG_ENDPOINT_NAME "rpmsg-tty"
#define HELLO_PERIOD_MS 500
#define HELLO_BURST_COUNT 50
#define RPMSG_STACK_SIZE 2048
#define RPMSG_THREAD_PRIORITY 7

#if !DT_HAS_CHOSEN(zephyr_ipc_shm)
#error "Shared memory for rpmsg is not defined in the device tree"
#endif

#if CONFIG_IPM_MAX_DATA_SIZE > 0
#define IPM_SEND(dev, w, id, d, s) ipm_send(dev, w, id, d, s)
#else
#define IPM_SEND(dev, w, id, d, s) ipm_send(dev, w, id, NULL, 0)
#endif

#define SHM_NODE DT_CHOSEN(zephyr_ipc_shm)
#define SHM_START_ADDR DT_REG_ADDR(SHM_NODE)
#define SHM_SIZE DT_REG_SIZE(SHM_NODE)

static const struct device *const ipm_handle = DEVICE_DT_GET(DT_CHOSEN(zephyr_ipc));

static K_THREAD_STACK_DEFINE(rpmsg_stack, RPMSG_STACK_SIZE);
static struct k_thread rpmsg_thread_data;

static struct rpmsg_virtio_device rvdev;
static struct rpmsg_device *rpdev;
static struct rpmsg_endpoint tty_ept;

static metal_phys_addr_t shm_physmap = SHM_START_ADDR;
static metal_phys_addr_t rsc_tab_physmap;
static struct metal_io_region shm_io_data;
static struct metal_io_region rsc_io_data;
static struct metal_io_region *const shm_io = &shm_io_data;
static struct metal_io_region *const rsc_io = &rsc_io_data;
static void *rsc_table;

static K_SEM_DEFINE(ipm_sem, 0, 1);
static K_SEM_DEFINE(peer_ready_sem, 0, 1);
static atomic_t peer_ready = ATOMIC_INIT(0);
static atomic_t peer_addr = ATOMIC_INIT(RPMSG_ADDR_ANY);

static void mark_peer_ready(uint32_t addr)
{
	atomic_set(&peer_addr, (int)addr);
	if (atomic_cas(&peer_ready, 0, 1) == 0) {
		k_sem_give(&peer_ready_sem);
	}
}

static void rpmsg_announce_channel(struct rpmsg_device *rdev, const char *name, uint32_t src);

static void platform_ipm_callback(const struct device *dev, void *context, uint32_t id,
				  volatile void *data)
{
	ARG_UNUSED(dev);
	ARG_UNUSED(context);
	ARG_UNUSED(id);
	ARG_UNUSED(data);

	k_sem_give(&ipm_sem);
}

static int mailbox_notify(void *priv, uint32_t id)
{
	ARG_UNUSED(priv);

	int ret = IPM_SEND(ipm_handle, 0, id, &id, sizeof(id));
	if (ret != 0) {
		LOG_ERR("IPM send failed: %d", ret);
	}

	return ret;
}

static int init_shared_resources(void)
{
	int rsc_size;
	struct metal_init_params metal_params = METAL_INIT_DEFAULTS;

	if (metal_init(&metal_params) != 0) {
		LOG_ERR("metal_init failed");
		return -EIO;
	}

	metal_io_init(shm_io, (void *)SHM_START_ADDR, &shm_physmap, SHM_SIZE, -1, 0,
		      addr_translation_get_ops(shm_physmap));

	rsc_table_get(&rsc_table, &rsc_size);
	rsc_tab_physmap = (uintptr_t)rsc_table;
	metal_io_init(rsc_io, rsc_table, &rsc_tab_physmap, rsc_size, -1, 0, NULL);

	if (!device_is_ready(ipm_handle)) {
		LOG_ERR("IPM device is not ready");
		return -ENODEV;
	}

	ipm_register_callback(ipm_handle, platform_ipm_callback, NULL);

	int status = ipm_set_enabled(ipm_handle, 1);
	if (status != 0) {
		LOG_ERR("ipm_set_enabled failed: %d", status);
		return status;
	}

	return 0;
}

static void cleanup_system(void)
{
	(void)ipm_set_enabled(ipm_handle, 0);
	if (rvdev.vdev != NULL) {
		rpmsg_deinit_vdev(&rvdev);
	}
	metal_finish();
}

static struct rpmsg_device *create_rpmsg_device(void)
{
	struct fw_rsc_vdev_vring *vring_rsc;
	struct virtio_device *vdev;

	vdev = rproc_virtio_create_vdev(VIRTIO_DEV_DEVICE, VDEV_ID,
					rsc_table_to_vdev(rsc_table),
					rsc_io, NULL, mailbox_notify, NULL);
	if (vdev == NULL) {
		LOG_ERR("Failed to create virtio device");
		return NULL;
	}

	rproc_virtio_wait_remote_ready(vdev);

	vring_rsc = rsc_table_get_vring0(rsc_table);
	if (rproc_virtio_init_vring(vdev, 0, vring_rsc->notifyid,
				    (void *)vring_rsc->da, rsc_io,
				    vring_rsc->num, vring_rsc->align) != 0) {
		LOG_ERR("Failed to init vring0");
		goto fail;
	}

	vring_rsc = rsc_table_get_vring1(rsc_table);
	if (rproc_virtio_init_vring(vdev, 1, vring_rsc->notifyid,
				    (void *)vring_rsc->da, rsc_io,
				    vring_rsc->num, vring_rsc->align) != 0) {
		LOG_ERR("Failed to init vring1");
		goto fail;
	}

	if (rpmsg_init_vdev(&rvdev, vdev, rpmsg_announce_channel, shm_io, NULL) != 0) {
		LOG_ERR("rpmsg_init_vdev failed");
		goto fail;
	}

	return rpmsg_virtio_get_rpmsg_device(&rvdev);

fail:
	rproc_virtio_remove_vdev(vdev);
	return NULL;
}

static void handle_notifications(k_timeout_t timeout)
{
	if (k_sem_take(&ipm_sem, timeout) == 0) {
		rproc_virtio_notified(rvdev.vdev, VRING1_ID);
	}
}

static int rpmsg_recv_callback(struct rpmsg_endpoint *ept, void *data, size_t len, uint32_t src,
			       void *priv)
{
	ARG_UNUSED(priv);
	ARG_UNUSED(ept);

	mark_peer_ready(src);
	const size_t msg_len = MIN(len, (size_t)32);
	LOG_INF("Host says: %.*s", (int)msg_len, (char *)data);

	return RPMSG_SUCCESS;
}

static void rpmsg_announce_channel(struct rpmsg_device *rdev, const char *name, uint32_t src)
{
	ARG_UNUSED(rdev);

	if (strcmp(name, RPMSG_ENDPOINT_NAME) != 0) {
		return;
	}

	mark_peer_ready(src);
	LOG_INF("rpmsg peer bound via name service (addr=%u)", src);
}

static int create_tty_endpoint(void)
{
	int ret = rpmsg_create_ept(&tty_ept, rpdev, RPMSG_ENDPOINT_NAME,
				   RPMSG_ADDR_ANY, RPMSG_ADDR_ANY,
				   rpmsg_recv_callback, NULL);
	if (ret != 0) {
		LOG_ERR("Could not create endpoint '%s': %d", RPMSG_ENDPOINT_NAME, ret);
		return ret;
	}

	LOG_INF("Endpoint '%s' created (src=%d)", RPMSG_ENDPOINT_NAME, tty_ept.addr);
	/* Linux rpmsg_tty picks up the endpoint immediately; pre-mark the peer
	 * so we start sending without waiting for a host-originated message.
	 */
	mark_peer_ready((uint32_t)tty_ept.addr);
	return 0;
}

static int wait_for_peer_bind(void)
{
	if (atomic_get(&peer_ready) == 1) {
		return 0;
	}

	LOG_INF("Waiting for rpmsg peer to bind to '%s'...", RPMSG_ENDPOINT_NAME);

	while (atomic_get(&peer_ready) == 0) {
		handle_notifications(K_MSEC(50));
		k_sem_take(&peer_ready_sem, K_MSEC(50));
	}
	LOG_INF("rpmsg peer ready (dest=%ld)", (long)atomic_get(&peer_addr));
	return 0;
}

static int send_hello_message(int counter)
{
	int dest = atomic_get(&peer_addr);

	if (dest == RPMSG_ADDR_ANY) {
		atomic_set(&peer_ready, 0);
		return -ENXIO;
	}

	char payload[64];
	int written = snprintk(payload, sizeof(payload),
			       "Hello World %d from %s\n", counter, CONFIG_BOARD);
	__ASSERT_NO_MSG(written > 0);

	int ret = rpmsg_sendto(&tty_ept, payload, written, (uint32_t)dest);
	if (ret < 0) {
		LOG_ERR("rpmsg_sendto failed: %d", ret);
		return ret;
	}

	return 0;
}

static void rpmsg_service(void *arg1, void *arg2, void *arg3)
{
	ARG_UNUSED(arg1);
	ARG_UNUSED(arg2);
	ARG_UNUSED(arg3);

	if (init_shared_resources() != 0) {
		LOG_ERR("Failed to init shared resources");
		return;
	}

	rpdev = create_rpmsg_device();
	if (rpdev == NULL) {
		LOG_ERR("Failed to create rpmsg device");
		cleanup_system();
		return;
	}

	if (create_tty_endpoint() != 0) {
		cleanup_system();
		return;
	}

	wait_for_peer_bind();

	for (int i = 0; i < HELLO_BURST_COUNT; i++) {
		handle_notifications(K_MSEC(10));

		int ret = send_hello_message(i);
		if (ret != 0) {
			LOG_WRN("send failed; retrying once bound again (ret=%d)", ret);
			wait_for_peer_bind();
		}

		k_msleep(HELLO_PERIOD_MS);
	}

	LOG_INF("Hello burst complete; keeping channel alive");

	while (true) {
		handle_notifications(K_MSEC(100));
	}
}

int main(void)
{
	LOG_INF("Starting RPMsg hello service");

	k_thread_create(&rpmsg_thread_data, rpmsg_stack, RPMSG_STACK_SIZE,
			rpmsg_service, NULL, NULL, NULL,
			RPMSG_THREAD_PRIORITY, 0, K_NO_WAIT);

	return 0;
}
