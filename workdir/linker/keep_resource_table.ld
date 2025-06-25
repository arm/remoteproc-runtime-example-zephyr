/*
 * Ensure the OpenAMP resource table is retained in the final image.
 *
 * Linux remoteproc requires a .resource_table section inside the ELF so it can
 * discover the vrings and other shared-memory metadata exposed by the remote
 * processor firmware.  The generic Zephyr linker script only keeps this
 * section when the SoC or board explicitly requests it.  Many Linux-side
 * boards (STM32MP1, i.MX8M, TI K3, …) already do this, but the i.MX93 one we
 * target here does not.
 *
 * We add a minimal linker snippet identical to what those boards use.  It is
 * injected with `zephyr_linker_sources(SECTIONS …)` from CMakeLists.txt.
 */

SECTION_PROLOGUE(.resource_table,, SUBALIGN(4)) {
    KEEP(*(.resource_table*))
} GROUP_LINK_IN(ROMABLE_REGION)
