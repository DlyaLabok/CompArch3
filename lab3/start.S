.syntax unified
.cpu cortex-m4
.thumb

.global _start
.section .isr_vector, "a", %progbits
.type vector_table, %object
vector_table:
    .word _estack
    .word Reset_Handler

.section .text
.thumb_func
.global Reset_Handler
Reset_Handler:
    ldr sp, =_estack
    bl bootloader_main

hang:
    b hang
