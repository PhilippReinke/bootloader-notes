bits 16

; initialised data
disk db 0x80
disk_error_message dw 11
db "Disk error!"

; https://wiki.osdev.org/Disk_access_using_the_BIOS_(INT_13h)#LBA_in_Extended_Mode
DAP:
	db 0x10
	db 0
	.num_sectors: 	dw 127
	.buf_offset: 	dw 0x0
	.buf_segment:	dw 0x0
	.LBA_lower: 	dd 0x0
	.LBA_upper: 	dd 0x0

disk_read_rm:
; Disk Read Real Mode - Load disk sectors to memory
; ax: start sector
; cx: number of sectors (512 bytes) to read
; bx: offset of buffer
; dx: segment of buffer
	.start:
		cmp cx, 127 ; (max sectors to read in one call = 127)
		jbe .good_size
		pusha
		mov cx, 127
		call disk_read_rm
		popa
		add eax, 127
		add dx, 127 * 512 / 16
		sub cx, 127
		jmp .start
	.good_size:
		mov [DAP.LBA_lower], ax
		mov [DAP.num_sectors], cx
		mov [DAP.buf_segment], dx
		mov [DAP.buf_offset], bx
		mov dl, [disk]
		mov si, DAP
		mov ah, 0x42
		int 0x13
		jc .print_error
		ret
	.print_error:
		mov si, disk_error_message
		call print_rm
		jmp $
