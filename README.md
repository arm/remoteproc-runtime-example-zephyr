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
All build and deploy commands are driven through the provided Makefile.

1. Build the Docker toolchain image (runs west and Zephyr SDK setup):
   ```bash
   make tools
   ```

2. Compile the Zephyr application:
   ```bash
   make build
   ```
   This creates a `build/` directory with the firmware binary.

3. Build the deployment image (contains the compiled firmware):
   ```bash
   make deploy
   ```
   The resulting Docker image `ambient-zephyr:latest` can be used to flash the board or further testing.

## Flashing to an Alif

To flash the Alif E7 you will need to register and download the Alif Security Toolkit from their website:

<https://alifsemi.com/support/software-tools/ensemble/>

Once you've downloaded and extracted the tools, use this script to copy the binary to the appropriate flashing location:


```sh
./scripts/copy_build_to_alif_tools.sh <PATH_TO_ALIF_TOOLS>
```

## Customization
- To change the target board, edit the `BUILD_CMD` in the Makefile or override with:
  ```bash
  make build BUILD_CMD="west build -b <your_board> . --build-dir build"
  ```
- Modify kernel and application settings in `prj.conf` as needed.
