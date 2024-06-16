[bits 64]

global _start

section .data
	hello_world db "Hello world!", 10
	hello_world_len equ $ - hello_world

section .text
	_start:
		mov rax, 1
		mov rdi, 1
		mov rsi, hello_world
		mov rdx, hello_world_len
		syscall

		mov rax, 60
		mov rdi, 0
		syscall
