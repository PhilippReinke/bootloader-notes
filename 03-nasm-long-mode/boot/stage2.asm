bits 16

; initialised data
stage2_message dw 19
db "Entering Stage 2..."
longmode_supported_message dw 23
db "Long mode is supported."
longmode_not_supported_message dw 27
db "Long mode is not supported."

stage2_entry:
	mov si, stage2_message
	call println_rm

	call is_longmode_supported
	test eax, eax
	jz long_mode_not_supported
	mov si, longmode_supported_message
	call println_rm

	call enable_a20
	call prepare_paging
	call remap_pic
	call enter_long_mode

long_mode_not_supported:
	mov si, longmode_not_supported_message
	call println_rm
	jmp $

%include "boot/stage2_a20.asm"
%include "boot/stage2_paging.asm"
%include "boot/stage2_pic.asm"
%include "boot/stage2_check_enter_lm.asm"
