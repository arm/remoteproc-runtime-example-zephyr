FROM zephyrprojectrtos/ci-base:v0.28.5 AS build
# 1. Install minimal Zephyr SDK for Arm
ARG SDK_VERSION=0.17.4
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/zephyr-sdk-${SDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
    tar -xf zephyr-sdk-${SDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
    rm zephyr-sdk-${SDK_VERSION}_linux-${HOSTTYPE}_minimal.tar.xz && \
    cd zephyr-sdk-${SDK_VERSION} && \
    ./setup.sh -t arm-zephyr-eabi -h -c
# 2. West init
WORKDIR /workspace
ADD west.yml .
RUN west init -l .
RUN west update --narrow --fetch-opt=--depth=1
ADD . .
# 3. Build
# List of boards supported by Zephyr: https://docs.zephyrproject.org/latest/boards/index.html
# Example usage:
# --build-arg BOARD=imx93_evk/mimx9352/m33
# --build-arg BOARD=stm32mp257f_dk/stm32mp257fxx/m33
ARG BOARD
RUN test -n "$BOARD" || (echo "BOARD not set" && false)
RUN west build -p -b $BOARD

FROM scratch
COPY --from=build /workspace/build/zephyr/zephyr.elf /zephyr.elf
ENTRYPOINT [ "zephyr.elf" ]
