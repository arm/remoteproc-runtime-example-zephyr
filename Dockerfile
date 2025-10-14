FROM zephyrprojectrtos/zephyr-build:v0.28.0 AS build

RUN west init
RUN git -C /workdir/zephyr fetch --all \
 && git -C /workdir/zephyr checkout 402adc4a3709c4be8f2f9f3cd10b1a2d838060a9

RUN west update

COPY workdir/ /workdir/

ENV SUPPORTED_BOARDS="imx93_evk/mimx9352/m33 stm32mp257f_dk/stm32mp257fxx/m33"
ARG BOARD="imx93_evk/mimx9352/m33"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN if printf '%s\n' $SUPPORTED_BOARDS | tr ' ' '\n' | grep -Fxq "$BOARD"; then \
      echo "Building for board: $BOARD"; \
      west build -b "$BOARD" && \
      cp build/zephyr/zephyr.elf /tmp/zephyr.elf; \
    else \
      echo "Error: Invalid BOARD value '$BOARD'"; \
      echo "Supported values: $SUPPORTED_BOARDS"; \
      exit 1; \
    fi

FROM scratch
COPY --from=build /tmp/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
