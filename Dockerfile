ARG ZEPHYR_VERSION="v0.26.8"

FROM zephyrprojectrtos/zephyr-build:${ZEPHYR_VERSION}

RUN west init
RUN west update

WORKDIR /project
COPY . ./

RUN west build -b imx93_evk/mimx9352/m33

FROM scratch
COPY --from=0 /project/build/zephyr/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
LABEL board="IMX93" mcu="ethos-u"
