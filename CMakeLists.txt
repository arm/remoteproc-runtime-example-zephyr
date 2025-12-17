cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(rpmsg_hello)

# Resource table goes into a dedicated linker section for remoteproc
zephyr_linker_sources(SECTIONS ${CMAKE_CURRENT_SOURCE_DIR}/resource_table.ld)

target_sources(app PRIVATE
  src/main.c
  src/stm32_ipcc_shim.c
)
