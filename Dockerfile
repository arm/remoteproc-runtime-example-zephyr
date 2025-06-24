FROM zephyrprojectrtos/zephyr-build:v0.28.0 AS build

RUN west init
RUN west update

COPY prj.conf /workdir/
COPY CMakeLists.txt /workdir/
COPY linker/ /workdir/linker
COPY src/ /workdir/src

RUN west build -b imx93_evk/mimx9352/m33 && \
    cp build/zephyr/zephyr.elf /tmp/zephyr.elf

FROM scratch
COPY --from=build /tmp/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
