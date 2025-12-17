FROM zephyrprojectrtos/ci-base:v0.28.5 AS build
ARG SDK_VERSION=0.17.4

RUN set -eu; \
    ARCH="$(uname -m)"; \
    mkdir -p /opt; \
    wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/zephyr-sdk-${SDK_VERSION}_linux-${ARCH}_minimal.tar.xz" && \
    tar -C /opt -xf "zephyr-sdk-${SDK_VERSION}_linux-${ARCH}_minimal.tar.xz" && \
    rm -f "zephyr-sdk-${SDK_VERSION}_linux-${ARCH}_minimal.tar.xz"

WORKDIR /opt/zephyr-sdk-${SDK_VERSION}
RUN ./setup.sh -t arm-zephyr-eabi -h -c

# 2. West init
WORKDIR /workspace
COPY west.yml .
RUN west init -l . && \
    west update --narrow --fetch-opt=--depth=1
COPY ipm_stm32_ipcc.patch /tmp/
RUN ZEPHYR_BASE="$(west list -f '{abspath}' zephyr)" && \
    patch -d "$ZEPHYR_BASE" -p1 < /tmp/ipm_stm32_ipcc.patch
COPY . .
# 3. Build
ARG BOARD
ARG DTC_OVERLAY_FILE=stm32mp257f_dk_stm32mp257fxx_m33.overlay
RUN test -n "$BOARD" || (echo "BOARD not set" && false) && \
    if [ -n "$DTC_OVERLAY_FILE" ]; then \
        west build -p -b "$BOARD" -- -DDTC_OVERLAY_FILE="$DTC_OVERLAY_FILE"; \
    else \
        west build -p -b "$BOARD"; \
    fi

FROM scratch
COPY --from=build /workspace/build/zephyr/zephyr.elf /zephyr.elf
ENTRYPOINT ["/zephyr.elf"]
