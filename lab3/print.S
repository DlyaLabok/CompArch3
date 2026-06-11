.syntax unified
.cpu cortex-m4
.thumb

.global print_str
.global print_hex

/*
 * print_str — виводить рядок з нульовим завершенням через Semihosting.
 *
 * Вхід:  r0 = вказівник на рядок (null-terminated)
 * Semihosting SYS_WRITE0 (0x04):
 *   r0 = номер операції (0x04)
 *   r1 = вказівник на рядок
 *   BKPT #0xAB — передає управління відладчику/QEMU
 */
.section .text
.thumb_func
print_str:
    push {r1-r3, lr}
    mov  r1, r0              @ r1 = вказівник на рядок
    mov  r0, #0x04           @ SYS_WRITE0
    bkpt #0xAB               @ Semihosting виклик
    pop  {r1-r3, pc}

/*
 * print_hex — виводить 32-бітне значення у шістнадцятковому форматі.
 *
 * Вхід:  r0 = значення (наприклад, 0x00000004)
 * Виводить 8 шістнадцяткових цифр у hex_buf, потім через SYS_WRITE0.
 */
.thumb_func
print_hex:
    push {r1-r7, lr}
    ldr  r1, =hex_buf        @ r1 = вказівник на буфер
    mov  r2, #8              @ 8 цифр (32 біти / 4)

.hex_loop:
    sub  r2, r2, #1
    and  r3, r0, #0xF        @ молодші 4 біти
    ldr  r4, =hex_chars
    ldrb r3, [r4, r3]        @ ASCII-символ цифри
    strb r3, [r1, r2]        @ зберігаємо в буфер
    lsr  r0, r0, #4          @ зсув вправо на 4 біти
    cmp  r2, #0
    bgt  .hex_loop

    @ Нульовий термінатор
    mov  r3, #0
    strb r3, [r1, #8]

    @ Виводимо буфер через Semihosting
    mov  r1, r1              @ r1 вже вказує на hex_buf
    mov  r0, #0x04           @ SYS_WRITE0
    bkpt #0xAB

    pop  {r1-r7, pc}

.section .rodata
hex_chars: .ascii "0123456789ABCDEF"

.section .data
hex_buf: .space 9
