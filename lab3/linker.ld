MEMORY
{
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 64K
}

_estack        = ORIGIN(RAM) + LENGTH(RAM);
_kernel_estack = 0x20008000;

SECTIONS
{
    .isr_vector :
    {
        . = ALIGN(4);
        KEEP(*(.isr_vector))
        . = ALIGN(4);
    } >FLASH

    .text :
    {
        . = ALIGN(4);
        *(.text)
        *(.text.*)
        . = ALIGN(4);
    } >FLASH

    .rodata :
    {
        . = ALIGN(4);
        *(.rodata)
        . = ALIGN(4);
    } >FLASH

    .data :
    {
        . = ALIGN(4);
        _sdata = .;
        *(.data)
        *(.data.*)
        _edata = .;
    } >RAM AT> FLASH

    .bss :
    {
        . = ALIGN(4);
        _sbss = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _ebss = .;
    } >RAM

    /*
     * Payload ядра: VMA = 0x20001000 (RAM), LMA = після .bss у Flash.
     * Bootloader копіює [_kernel_flash_start .. +_kernel_size] -> 0x20001000.
     * Оскільки VMA = RAM, всі адреси в literal pool та kernel_vector
     * будуть RAM-адресами (правильно!).
     */
    .kernel_payload 0x20001000 :
    {
        . = ALIGN(4);
        _kernel_ram_start = .;
        KEEP(*(.kernel_vector))
        . = ALIGN(4);
        *(.kernel_text)
        . = ALIGN(4);
        *(.kernel_data)
        . = ALIGN(4);
        _kernel_ram_end = .;
    } >RAM AT> FLASH

    _kernel_flash_start = LOADADDR(.kernel_payload);
    _kernel_size        = SIZEOF(.kernel_payload);
}
