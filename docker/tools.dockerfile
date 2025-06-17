ARG ZEPHYR_VERSION="v0.26.8"

FROM zephyrprojectrtos/zephyr-build:${ZEPHYR_VERSION}

RUN west init
RUN west update
