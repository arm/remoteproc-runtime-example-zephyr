# topo-ambient-zephyr

A minimal Zephyr RTOS project for the NXP iMX93 development kit which flashes a minimal "Hello World" application that prints the target board name at startup.

## Features
  - Uses Zephyr RTOS
  - Builds for the `imx93_evk/mimx9352/m33` board by default
  - Dockerized multistage image for reproducible builds

## Dependencies
The build is container-based; the host machine only needs the tools that
bootstrap the containerised build:

- Docker – to run the build and deploy container

## Usage

```bash
# Pre-fetch the base image
# this will save a lot of time when building as docker wont otherwise cache layers this large
docker pull zephyrprojectrtos/zephyr-build:v0.28.0

# Build container
docker build -t ambient-zephyr .
# Copy to topo
docker save ambient-zephyr | ssh root@topo.local 'docker load'
# Launch
ssh root@topo.local 'docker run -d --runtime io.containerd.remoteproc.v1 --annotation remoteproc.mcu=imx-rproc ambient-zephyr'
```
