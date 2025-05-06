# PLATFORM = linux/arm64
# IMAGE_DOCKERFILE= image.dockerfile
# IMAGE_NAME = ambient-zephyr:latest

RUNTIME_ROOT = sdk-alif
WORKDIR = /runtime
VOLUME_RUNTIME = -v $(abspath $(RUNTIME_ROOT)):$(WORKDIR)
BUILD_CMD = west init && west build -b alif_e7_dk_rtss_he zephyr/samples/hello_world
RUNTIME_IMAGE = zephyrprojectrtos/zephyr-build:main

# SHIM_ROOT = ../runtime/shim
# VOLUME_SHIM = -v $(abspath $(SHIM_ROOT)):$(WORKDIR)
# RUNTIME_DOCKERFILE = runtime.dockerfile



image: image.dockerfile
	docker run --init --rm $(VOLUME_RUNTIME) -w $(WORKDIR) $(RUNTIME_IMAGE) $(BUILD_CMD)
#	docker build -t ${IMAGE_NAME} -f ${IMAGE_DOCKERFILE} .

# runtime-build: runtime.dockerfile
# 	docker build -t $(RUNTIME_IMAGE) -f $(RUNTIME_DOCKERFILE) .

# runtime-run: runtime-build
# 	docker run --init --rm $(VOLUME_RUNTIME) -w $(WORKDIR) $(RUNTIME_IMAGE) $(BUILD_CMD)

# shim: runtime.dockerfile
# 	docker run --init --rm $(VOLUME_SHIM) -w $(WORKDIR) $(RUNTIME_IMAGE) $(BUILD_CMD)

# all: runtime-run shim
