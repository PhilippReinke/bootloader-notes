bits 16

; initialised data
a20_enabled_message dw 15
db "A20 is enabled."
a20_disabled_message dw 16
db "A20 is disabled."
a20_trying_bios dw 34
db "Trying to enable A20 using BIOS..."
a20_trying_keyb dw 49
db "Trying to enable A20 using Keyboard Controller..."
a20_trying_io92 dw 40
db "Trying to enable A20 using IO port 92..."

enable_a20:
	; check if A20 is already enabled.
	call check_a20
	test ax, ax
	jnz .end

	; try to enable A20 using BIOS.
	mov si, a20_trying_bios
	call println_rm
	call enable_a20_using_bios

	; check if A20 is enabled
	call check_a20
	test ax, ax
	jnz .end

	; try to enable A20 using keyboard controller
	mov si, a20_trying_keyb
	call println_rm
	call enable_a20_using_keyboard_controller

	; check if A20 is enabled
	call check_a20
	test ax, ax
	jnz .end

	; try to enable A20 using IO port 92h (fast A20 method)
	mov si, a20_trying_io92
	call println_rm
	call enable_a20_using_keyboard_controller

	; check if A20 is enabled.
	call check_a20
	test ax, ax
	jnz .end

	jmp $
	.end:
		ret

check_a20:
	; check status of A20 line.
	call real_mode_check_a20
	test ax, ax
	jnz .a20_enabled
		mov si, a20_disabled_message
		call println_rm
		ret
	.a20_enabled:
		mov si, a20_enabled_message
		call println_rm
		ret

real_mode_check_a20:
; Check the status of the A20 line (in real mode).
; ax = 0 if the a20 line is disabled (memory wraps around)
; ax = 1 if the a20 line is enabled (memory does not wrap around)
	pushf
	push ds
	push es
	push di
	push si
	cli 	; clear interrupts

	xor ax, ax 		; ax = 0
	mov es, ax 		; es = 0
	not ax 			; ax = 0xffff
	mov ds, ax 		; ds = 0xffff
	mov di, 0x0500 	; 0500 and 0510 are chosen since they are guaranteed to be free
	mov si, 0x0510 	; for use at any point of time after BIOS initialization.

	; save original values found at these addresses.
	mov dl, byte [es:di]
	push dx
	mov dl, byte [ds:si]
	push dx

	mov byte [es:di], 0x00 	; [es:di] is 0:0500
	mov byte [ds:si], 0xFF 	; [ds:si] is FFFF:0510
	cmp byte [es:di], 0xFF 	; if the A20 line is disabled, [es:di] will contain 0xFF
							; (as the write to [ds:si] really occured to 00500).

	; A20 disabled ([es:di] equal to 0xFF).
	mov ax, 0
	je .a20_disabled
	mov ax, 1 ; A20 enabled.

	.a20_disabled:
		; restore original values
		pop dx
		mov byte [ds:si], dl
		pop dx
		mov byte [es:di], dl

		pop si
		pop di
		pop es
		pop ds
		popf
		sti ; enable interrupts
		ret


enable_a20_using_bios:
; Try to enable A20 gate using the BIOS (int 15h, ax = 2401h)
; ax = 0 (Failure)
; ax = 1 (Success)
	mov ax,2403h 	; query A20 gate support (later PS/2s systems)
	int 15h
	jb .failure 	; int 15h is not supported
	cmp ah, 0
	jnz .failure 	; int 15h is not supported
	mov ax, 2402h 	; get A20 gate status
	int 15h
	jb .failure 	; couldn't get status
	cmp ah, 0
	jnz .failure 	; couldn't get status
	cmp al, 1
	jz .success 	; A20 is already activated
	mov ax, 2401h 	; enable A20 gate
	int 15h
	jb .failure 	; couldn't enable the A20 gate
	cmp ah, 0
	jnz .failure 	; couldn't enable the A20 gate
   .success:
		mov ax, 1
		ret
   .failure:
		mov ax, 0
		ret

disable_A20_using_BIOS:
; Try to disable A20 gate using the BIOS (int 15h, ax = 2400h)
	mov ax, 2400h
	int 15h
	ret

enable_a20_using_keyboard_controller:
; Try to enable A20 line using the Keyboard Controller (chip 8042)
; ax = 0 (Failure)
; ax = 1 (Success)
	cli 			; clear interrupts
	call a20wait
	mov al, 0xAD 	; disable keyboard
	out 0x64, al
	call a20wait
	mov al, 0xD0 	; read from input
	out 0x64, al
	call a20wait2
	in al,0x60
	push eax
	call a20wait
	mov al, 0xD1 	; write to output
	out 0x64, al
	call a20wait
	pop eax
	or al, 2
	out 0x60, al
	call a20wait
	mov al, 0xAE 	; enable keyboard
	out 0x64, al
	call a20wait
	sti 			; enables interrupts
	ret

a20wait:
	in al, 0x64
	test al, 2
	jnz a20wait
	ret

a20wait2:
	in al, 0x64
	test al, 1
	jz a20wait2
	ret

enable_a20_using_IO_port_92:
; Enable A20 Line via IO port 92h (Fast A20 method)
; This method is quite dangerous because it may cause conflicts with
; some hardware devices forcing the system to halt.
; Bits of port 92h
; Bit 0 - Setting to 1 causes a fast reset
; Bit 1 - 0: disable A20, 1: enable A20
; Bit 2 - Manufacturer defined
; Bit 3 - power on password bytes. 0: accessible, 1: inaccessible
; Bits 4-5 - Manufacturer defined
; Bits 6-7 - 00: HDD activity LED off, 01 or any value is "on"
	in al, 0x92  ; Read from port 0x92
	test al, 2   ; Check if bit 1 (i.e. the 2nd bit) is set.
	jnz .end     ; If bit 1 (i.e. the 2nd bit) is already set don't do anything.
	or al, 2     ; Activate bit 1 (i.e. the 2nd bit).
	and al, 0xfe ; Make sure bit 0 is 0 (it causes a fast reset).
	out 0x92, al ; Write to port 0x92
   .end:
	ret
