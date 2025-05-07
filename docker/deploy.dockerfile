FROM scratch

COPY zephyr/zephyr.elf /zephyr.elf

ENTRYPOINT [ "/zephyr.elf" ]
LABEL board="Alif E7-DK" mcu="ethos-u"
