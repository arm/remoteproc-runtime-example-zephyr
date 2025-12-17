# Remoteproc Runtime example for Zephyr

A minimal Zephyr RTOS project for the STM32MP257F Cortex-M33 core that now exposes its console over RPMsg (rpmsg-tty). The resulting image is compatible with [Remoteproc Runtime](https://github.com/Arm/remoteproc-runtime) and can be read directly from Linux without physical UART access.

# Usage

## With Docker

Pre-fetch the base image - this will save a lot of time when rebuilding building as docker won't otherwise cache layers this large:
```shell
docker pull zephyrprojectrtos/ci-base:v0.28.5
```

Build an image to use with Remoteproc Runtime:

```shell
docker build --build-arg BOARD=<your board name> .
```

For example:

```shell
docker build --build-arg BOARD=stm32mp257f_dk/stm32mp257fxx/m33 \
  --build-arg DTC_OVERLAY_FILE=stm32mp257f_dk_stm32mp257fxx_m33.overlay .
```

See list of [boards supported by Zephyr](https://docs.zephyrproject.org/latest/boards/index.html).

## Viewing M33 output from Linux (no UART required)

1. Build and deploy to the board:
   ```bash
   ./deploy-to-board.sh
   ```
2. Start the remote processor from Linux:
   ```bash
   docker run \
     --runtime io.containerd.remoteproc.v1 \
     --annotation remoteproc.name="imx-rproc" \
     --network=host \
     remoteproc-runtime-example-zephyr:latest
   ```
3. Watch the RPMsg TTY stream from Linux:
   ```bash
   cat /dev/ttyRPMSG0
   ```

You should see repeated `Hello World N from stm32mp257f_dk/stm32mp257fxx/m33` messages from the Cortex-M33, even without the serial console connected.
