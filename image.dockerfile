FROM zephyrprojectrtos/zephyr-build:main as buildenv

RUN mkdir /sdk-alif
WORKDIR /sdk-alif
RUN west init -m https://github.com/alifsemi/sdk-alif --mr v1.3.0 /sdk-alif
RUN west update

# WORKDIR /mcuxsdk/examples/evkmimx8mp/demo_apps/hello_world/armgcc

RUN west build -b alif_e7_dk_rtss_he zephyr/samples/hello_world

# RUN export ARMGCC_DIR=/usr/ && sh ./build_release.sh

# FROM scratch as firmware
# COPY --from=buildenv /mcuxsdk/examples/evkmimx8mp/demo_apps/hello_world/armgcc/release/hello_world.elf  /hello_world.elf
# ENTRYPOINT [ "/hello_world.elf" ]
# LABEL board="NXP i.MX8MPlus EVK board" mcu="imx-rproc"
