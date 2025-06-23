FROM scratch

COPY zephyr/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
LABEL board="IMX93" mcu="ethos-u"
