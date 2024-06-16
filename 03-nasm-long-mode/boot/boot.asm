; Stage 1 (16 bit real mode)
; MBR with 512 bytes that ends with the magic number 0xaa55 (0x55 0xaa in little
; endian). The BIOS loads these 512 bytes to 0x7c00 and excutes the code that
; will...
; - load code beyond theses 512 bytes into RAM (until stage3_end to be precise)
; - print a message
; - jump to stage 2
stage1_start:
	times 90 db 0 ; BIOS parameter block
	%include "boot/stage1.asm"
stage1_end:

; Stage 2 (16 bit real mode)
; Prepare and switch to 64-bit long mode. This is done by
; - checking support for long mode
; - enabling a20
; - setting up a general descriptor table and page table at 0x9000
; - remapping the programmable interrupt controller (pic)
; - jumping to stage 3
stage2_start:
	%include "boot/stage2.asm"
	align 512, db 0
stage2_end:

; Stage 3 (64 bit long mode)
; Set up an Interrupt Descriptor Table (IDT) with according handlers (aka
; Interrupt Service Routines).
stage3_start:
	%include "boot/stage3.asm"
	align 512, db 0
stage3_end:
