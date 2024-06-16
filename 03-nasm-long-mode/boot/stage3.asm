bits 64

; initialised data
hello_world_message dw 12
db "Hello World!"

; includes
%include "boot/stage3_print.asm"
%include "boot/stage3_idt.asm"
%include "boot/stage3_isr.asm"

stage3_entry:
	lidt [IDTR] 		; load our IDT

	mov al, 0x80 		; OCW1: unmask all interrupts at master PIC
	out PIC1_DATA, al
	mov al, 0x80 		; OCW1: unmask all interrupts at master PIC
	out PIC2_DATA, al

	; clear the screen
	; set background color to black (0) and
	; character to blank space (20)
	mov rax, 0x0020002000200020
	call fill_screen

	; print "Hello World!" at the upper right corner
	mov ah, 0x1e
	mov r8, 69
	mov r9, 1
	mov rsi, hello_world_message
	call print

	; uncomment to trigger exception
	; trigger "Division by zero"
	; mov eax, 2024
	; mov ecx, 0
	; div ecx

	.loop:
		; print system timer ticks
		mov ah, VGA_COLOR_LIGHT_GREEN
		mov r8, 1
		mov r9, 2
		mov r10, [systimer_ticks]
		call print_hex

		; print keyboard scan code
		mov r10, [keyboard_scancode]
		mov ah, VGA_COLOR_LIGHT_CYAN
		mov r8, 1
		mov r9, 4
		call print_hex

		jmp .loop
