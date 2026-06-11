.syntax unified
.cpu cortex-m4
.thumb

.global bootloader_main
.type bootloader_main, %function

bootloader_main:
    push {r4-r7, lr}

    @ --- Повідомлення про старт ---
    ldr  r0, =boot_msg
    bl   print_str

    /*
     * Копіюємо payload ядра з Flash у RAM.
     *
     * _kernel_flash_start — LMA у Flash (звідки читаємо)
     * _kernel_ram_start   — VMA в RAM   (куди пишемо)
     * _kernel_size        — розмір у байтах
     *
     * Використовуємо LDR з post-increment і STR з post-increment,
     * як вимагає завдання.
     */
    ldr  r0, =_kernel_flash_start  @ r0 = Flash-джерело
    ldr  r1, =_kernel_ram_start    @ r1 = RAM-призначення
    ldr  r2, =_kernel_size         @ r2 = кількість байт

copy_loop:
    cmp  r2, #0
    ble  copy_done
    ldr  r3, [r0], #4              @ LDR: читаємо слово з Flash, r0 += 4
    str  r3, [r1], #4              @ STR: пишемо слово в RAM,   r1 += 4
    subs r2, r2, #4
    b    copy_loop

copy_done:
    @ --- Повідомлення про завершення копіювання ---
    ldr  r0, =copy_msg
    bl   print_str

    /*
     * Передаємо управління ядру в RAM.
     *
     * Вектор ядра скопійований на початок RAM (0x20001000):
     *   [_kernel_ram_start + 0] = SP  ядра  (_kernel_estack)
     *   [_kernel_ram_start + 4] = Thumb-адреса kernel_Reset_Handler (RAM!)
     *
     * Завдяки правильним VMA у linker.ld, поле [+4] вже містить
     * RAM-адресу, тому BX одразу переходить у RAM.
     */
    ldr  r4, =_kernel_ram_start
    ldr  r0, [r4]          @ завантажуємо SP ядра
    msr  msp, r0           @ встановлюємо MSP
    ldr  r1, [r4, #4]      @ завантажуємо Thumb-адресу kernel_Reset_Handler
    bx   r1                @ стрибаємо в RAM (Thumb bit вже встановлений)

.section .rodata
boot_msg:  .asciz ">> Bootloader started.\r\n"
copy_msg:  .asciz ">> Kernel copied to RAM. Starting...\r\n"
