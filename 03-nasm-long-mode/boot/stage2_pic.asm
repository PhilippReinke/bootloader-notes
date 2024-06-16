bits 16

PIC1_COMMAND 	equ 0x20 ; command port of 1st PIC
PIC1_DATA 		equ 0x21 ; data port of 1st PIC
PIC2_COMMAND 	equ 0xa0 ; command port of 2nd PIC
PIC2_DATA 		equ 0xa1 ; data port of 2nd PIC
PIC_EOI 		equ 0x20 ; EOI (End of interrupt) command (=0x20)

ICW1_ICW4 		equ 0x01 ; initialization command word 4 is needed
ICW1_SINGLE 	equ 0x02 ; single mode (0: cascade mode)
ICW1_INTERVAL4 	equ 0x04 ; call address interval 4 (0: 8)
ICW1_LEVEL 		equ 0x08 ; level triggered mode (0: edge mode)
ICW1_INIT 		equ 0x10 ; initialization - required!

ICW4_8086 		equ 0x01 ; 8086/88 mode (0: MCS-80/85 mode)
ICW4_AUTO_EOI 	equ 0x02 ; auto end of interrupt (0: normal EOI)
ICW4_BUF_SLAVE 	equ 0x08 ; buffered mode/slave
ICW4_BUF_MASTER equ 0x0c ; buffered mode/master
ICW4_SFNM 		equ 0x10 ; special fully nested mode

remap_pic:
; In protected / long mode, the IRQs 0-15 conflict with the CPU exceptions
; (which are reserved up until 0x1f). It is thus recommended to change the
; programmable interrupt controller's offsets (remapping the PIC) so that
; IRQs use non-reserved vectors.
; A common choice is to move them to the beginning of the available range:
; IRQs 0..15 -> int 0x20..0x2f (30..47). For that, we need to set the 1st
; PIC's offset to 0x20 (32) and the 2nd's to 0x28 (40).
	push ax

	; disable IRQs
	mov al, 0xff 		; out 0xFF to 0xA1 and 0x21 to mask/disable all IRQs.
	out PIC1_DATA, al
	out PIC2_DATA, al
	nop
	nop

	; remap PIC
	; ICW1: send initialization command (=0x11) to both PICs
	mov al, ICW1_INIT | ICW1_ICW4
	out PIC1_COMMAND, al
	out PIC2_COMMAND, al
	; ICW2: set vector offset of 1st PIC to 0x20 (i.e. IRQ0 => int 32)
	mov al, 0x20
	out PIC1_DATA, al
	; ICW2: set vector offset of 2nd PIC to 0x28 (i.e. IRQ8 => int 40)
	mov al, 0x28
	out PIC2_DATA, al
	; ICW3: tell 1st PIC that there is a 2nd PIC at IRQ2 (= 00000100)
	mov al, 4
	out PIC1_DATA, al
	; ICW3: tell 2nd PIC its "cascade" identity (= 00000010)
	mov al, 2
	out PIC2_DATA, al
	; ICW4: set mode to 8086/88 mode
	mov al, ICW4_8086
	out PIC1_DATA, al
	out PIC2_DATA, al

	; OCW1: We mask all interrupts (until we set a proper IDT in kernel)
	mov al, 0xFF
	out PIC1_DATA, al
	out PIC2_DATA, al

	pop ax
	ret
