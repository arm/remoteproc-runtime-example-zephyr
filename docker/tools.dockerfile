ARG ZEPHYR_VERSION="v0.26.8"
ARG ALIF_VERSION="v1.3.0"

FROM zephyrprojectrtos/zephyr-build:${ZEPHYR_VERSION}
ARG ALIF_VERSION

RUN west init -m https://github.com/alifsemi/sdk-alif --mr ${ALIF_VERSION}
RUN west update
