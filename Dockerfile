ARG ZEPHYR_VERSION="v0.26.8"

FROM zephyrprojectrtos/zephyr-build:${ZEPHYR_VERSION}

RUN west init
RUN west update

COPY . /workdir

RUN --mount=type=cache,uid=1000,gid=1000,target=/workdir/build \
    west build -b imx93_evk/mimx9352/m33 \
    && cp build/zephyr/zephyr.elf /tmp/zephyr.elf

FROM scratch
COPY --from=0 /tmp/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
LABEL board="IMX93" mcu="ethos-u"
