bits 16

; initialised data
newline dw 2
db 13,10 ; \r\n
stage1_message dw 17
db "Stage 1 finished."

print_rm:
; Print Real Mode
; si: pointer to string with number of characters as 1st 16 bits
	push ax
	push cx
	push si
	mov cx, word [si]
	add si, 2
	.string_loop:
		lodsb
		mov ah, 0eh
		int 10h
	loop .string_loop, cx
	pop si
	pop cx
	pop ax
	ret

println_rm:
; Print Line in Real Mode
; si: pointer to string with number of characters as 1st 16 bits
	push si
	call print_rm
	mov si, newline
	call print_rm
	pop si
	ret
