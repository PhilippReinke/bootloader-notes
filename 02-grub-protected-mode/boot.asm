global start

section .text
bits 32
start:
    mov word [0xb8000], 0x2f47
    mov word [0xb8002], 0x2f52
    mov word [0xb8004], 0x2f55
    mov word [0xb8006], 0x2f42
    jmp $
