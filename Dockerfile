FROM zephyrprojectrtos/zephyr-build:v0.28.0 AS build

RUN west init
RUN west update

ADD workdir/ /workdir/

RUN west build -b imx93_evk/mimx9352/m33 && \
    cp build/zephyr/zephyr.elf /tmp/zephyr.elf

FROM scratch
COPY --from=build /tmp/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
