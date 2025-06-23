# mandalay-ambient-zephyr

A minimal Zephyr RTOS project for the NXP iMX93 development kit which flashes a minimal "Hello World" application that prints the target board name at startup.

## Features
  - Uses Zephyr RTOS
  - Builds for the `imx93_evk/mimx9352/m33` board by default
  - Dockerized toolchain and deployment images for reproducible builds

## Dependencies
The build is container-based; the host machine only needs the tools that
bootstrap the containerised build:

- Docker – to run the build and deploy containers
- GNU make – to invoke the Makefile targets

## Usage

```sh
# compile firmware only
make build

# compile **and** package into a deployment container (default target)
make        # same as `make deploy`
```

The Zephyr binary is written to `build/zephyr/zephyr.bin`.
