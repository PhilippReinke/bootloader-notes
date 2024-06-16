bits 16
org 0x7c00

; Some BIOS may load us at 0x0000:0x7c00 while others at 0x07c0:0x0000.
; We do a far jump to accommodate for this issue (cs is reloaded to 0x0000).
jmp 0x0000:setup_segments
setup_segments:
	xor ax, ax 				; set ax to zero
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, stage1_start 	; stack above 0x7c00
	cld 					; clear direction flag
	mov [disk], dl			; dl contains booted drive number

mov ax, (stage2_start-stage1_start)/512	; start sector
mov cx, (stage3_end-stage2_start)/512 	; number of sectors (512 bytes) to read
mov bx, stage2_start 					; bx: offset of buffer
xor dx, dx 								; dx: segment of buffer
call disk_read_rm

mov si, stage1_message
call println_rm

jmp stage2_entry

%include "boot/stage1_disk.asm"
%include "boot/stage1_print.asm"

times 510-($-$$) db 0 	; padding
dw 0xaa55				; magic number
