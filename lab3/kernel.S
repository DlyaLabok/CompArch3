.syntax unified
.cpu cortex-m4
.thumb

/*
 * kernel_vector — перші 8 байт payload у Flash/RAM.
 * SP (kernel_estack) та адреса kernel_Reset_Handler.
 * Завдяки VMA=RAM в linker.ld, адреса kernel_Reset_Handler
 * буде RAM-адресою автоматично.
 */
.section .kernel_vector, "a", %progbits
.type kernel_vector, %object
kernel_vector:
    .word _kernel_estack           /* SP ядра */
    .word kernel_Reset_Handler + 1 /* Thumb-адреса Reset Handler в RAM */

/*
 * Код ядра (VMA = RAM, LMA = Flash).
 * Literal pool компілюється з RAM VMA — тому всі адреси правильні.
 */
.section .kernel_text, "ax", %progbits
.thumb_func
.global kernel_Reset_Handler
kernel_Reset_Handler:
    /*
     * Варіант 1: |4 * x|, де x = 1
     *
     * Демонструємо:
     *   LDR  — зчитування x з пам'яті
     *   LSL  — множення на 4 зсувом вліво на 2 біти
     *   ADD  — інкремент лічильника
     *   STR  — збереження результату (4 байти) у пам'ять
     */

    @ --- Записуємо x = 1 у пам'ять ---
    ldr  r0, =var_x        @ r0 = RAM-адреса var_x
    mov  r1, #1
    str  r1, [r0]          @ [var_x] = 1

    @ --- Обчислення: x * 4 = 4 ---
    ldr  r1, [r0]          @ r1 = x = 1        (LDR з RAM)
    lsl  r1, r1, #2        @ r1 = x << 2 = 4   (множення на 4)

    @ --- Інкремент лічильника ---
    ldr  r2, =counter
    ldr  r3, [r2]
    add  r3, r3, #1        @ r3 = counter + 1  (ADD)
    str  r3, [r2]          @ [counter] = r3

    @ --- Зберігаємо результат ---
    ldr  r2, =var_result
    str  r1, [r2]          @ [var_result] = 4  (STR 4 байти)

    @ --- Виводимо результат через Semihosting ---
    ldr  r0, =res_msg
    bl   print_str

    ldr  r0, =var_result
    ldr  r0, [r0]          @ r0 = 4
    bl   print_hex

    ldr  r0, =newline_msg
    bl   print_str

hang_kernel:
    b    hang_kernel

/*
 * Змінні ядра (VMA = RAM).
 * Literal pool вище посилається на ці RAM-адреси.
 */
.section .kernel_data, "aw", %progbits
var_x:      .word 0
var_result: .word 0
counter:    .word 0

/* Рядки залишаються у Flash — вони read-only, читаємо з Flash нормально */
.section .rodata
res_msg:     .asciz "Result of |4*x| (x=1) = 0x"
newline_msg: .asciz "\r\n"
