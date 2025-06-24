# mandalay-ambient-zephyr

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
docker build -t mandalay-ambient-zephyr .
```
