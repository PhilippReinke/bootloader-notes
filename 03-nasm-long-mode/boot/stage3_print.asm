bits 64

; definitions
%define VRAM 0xb8000

%define VGA_COLOR_BLACK 		0
%define VGA_COLOR_BLUE 			1
%define VGA_COLOR_GREEN 		2
%define VGA_COLOR_CYAN 			3
%define VGA_COLOR_RED 			4
%define VGA_COLOR_MAGENTA 		5
%define VGA_COLOR_BROWN 		6
%define VGA_COLOR_LIGHT_GREY 	7
%define VGA_COLOR_DARK_GREY 	8
%define VGA_COLOR_LIGHT_BLUE 	9
%define VGA_COLOR_LIGHT_GREEN 	10
%define VGA_COLOR_LIGHT_CYAN 	11
%define VGA_COLOR_LIGHT_RED 	12
%define VGA_COLOR_LIGHT_MAGENTA	13
%define VGA_COLOR_LIGHT_BROWN 	14
%define VGA_COLOR_WHITE 		15

%define VGA_WIDTH	80
%define VGA_HEIGHT	25

fill_screen:
; rax (XY__XY__XY__XY__): X = background colour, Y = character colour
; rax (__ZZ__ZZ__ZZ__ZZ): ASCII code of character to use to fill the screen
	mov rdi, VRAM
	mov rcx, 500 		; 80*25 / 4 = 500 (we set 4 characters each time)
	rep stosq 			; clear the entire screen.
	ret

print:
; rsi: pointer to string (first 16 bits = the number of characters in the string)
; ah: Color attributes
; r8: x
; r9: y
	push rsi
	push rax
	push r8
	push r9
	dec r8
	add r8, r8
	dec r9
	mov rdi, VRAM
	push rax
	mov rax, VGA_WIDTH*2
	mul r9
	add r8, rax
	pop rax
	mov cx, word [rsi] 	; first 16 bits = the number of characters in the string
	inc rsi
	.string_loop:		; print all the characters in the string
		lodsb
		mov al, byte [rsi]
		mov [rdi+r8], ax
		add rdi, 2
	loop .string_loop
	pop r9
	pop r8
	pop rax
	pop rsi
	ret

print_hex:
; Prints a 16-digit hexadecimal value
; r10: value to be printed
; ah: colour attributes
	push r10
	sub rsp, 20 				; make space for the string length (2 bytes) and 18 characters
	mov rsi, rsp
	push rsi 					; store rsi (string address)
	mov [rsi], word 18 			; string length = 17
	mov [rsi+2], word "0x"
	add rsi, 19 				; point rsi to the end of the string
	mov ecx, 16 				; loop 16 times (one for each digit)
	.digit:
		push r10 				; store rax
		and r10, 0Fh 			; isolate digit
		add r10b, "0"			; convert to ascii
		cmp r10b,"9" 			; is hex?
		jbe .nohex
		add r10b, 7 			; hex
		.nohex:
		mov [rsi], byte r10b 	; store result
		dec rsi 				; next position
		pop r10 				; restore rax
		shr r10, 4 				; right shift by 4
	loop .digit
	pop rsi 					; restore rsi (string address)
	call print
	add rsp, 20
	pop r10
	ret
