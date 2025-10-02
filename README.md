# Remoteproc Runtime example for Zephyr

A minimal Zephyr RTOS project which flashes a minimal "Hello World" application that prints the target board name at startup. The resulting image is compatible with [Remoteproc Runtime](https://github.com/Arm/remoteproc-runtime).

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
docker build --build-arg BOARD=imx93_evk/mimx9352/m33 .
```

See list of [boards supported by Zephyr](https://docs.zephyrproject.org/latest/boards/index.html).
