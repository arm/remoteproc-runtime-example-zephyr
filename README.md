# mandalay-ambient-zephyr

A minimal Zephyr RTOS project for the Alif E7 development kit which flashes a minimal "Hello World" application that prints the target board name at startup.

## Features
  - Uses Zephyr RTOS
  - Builds for the `alif_e7_dk_rtss_hp` board by default
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

## Flashing the binary to an Alif

To flash the Alif E7 you will need to register and download the Alif Security Toolkit from their website:

<https://alifsemi.com/support/software-tools/ensemble/>

Once you've downloaded and extracted the tools, use this script to copy the binary to the appropriate flashing location:


```sh
./scripts/copy_build_to_alif_tools.sh <PATH_TO_ALIF_TOOLS>
```
