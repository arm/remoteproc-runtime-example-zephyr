FROM zephyrprojectrtos/zephyr-build:v0.28.0 AS build

RUN west init
RUN west update

ADD workdir/ /workdir/

ENV SUPPORTED_BOARDS="imx93_evk/mimx9352/m33 stm32mp257f_dk/stm32mp257fxx/m33"
ARG BOARD="imx93_evk/mimx9352/m33"
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
