# mandalay-ambient-zephyr

A minimal Zephyr RTOS project for the Alif E7 development kit which flashes a minimal "Hello World" application that prints the target board name at startup.

## Features
  - Uses Zephyr RTOS
  - Builds for the `alif_e7_dk_rtss_he` board by default
  - Dockerized toolchain and deployment images for reproducible builds

## Dependencies
- CMake >= 3.20
- Docker

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

## Flashing

TODO

## Customization
- To change the target board, edit the `BUILD_CMD` in the Makefile or override with:
  ```bash
  make build BUILD_CMD="west build -b <your_board> . --build-dir build"
  ```
- Modify kernel and application settings in `prj.conf` as needed.
