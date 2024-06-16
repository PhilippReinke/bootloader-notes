print_string:
	pusha
	mov ah, 0x0e
	mov al, [bx]
	print_loop:
		int 0x10
		inc bx
		mov al, [bx]
		cmp al, 0
		jne print_loop
	call print_linebreak
	popa
	ret

print_linebreak:
	pusha
	mov ah, 0x0e
	mov al, 13
	int 0x10
	mov al, 10
	int 0x10
	popa
	ret
