; Interrupt Descriptor Table (IDT)
;
; The Interrupt Descriptor Table (IDT) is a data structure used to implement an
; Interrupt Vector Table (IVT), i.e. to determine the proper response to three
; types of events:
; 	- hardware interrupts
; 	- software interrupts
;	- processor
; exceptions. The IDT consists of 256 interrupt vectors, the first 32 (0-31 or
; 0x00-0x1f) of which are used for processor exceptions.
BASE_OF_SECTION equ 0x8000

; macro for an IDT entry
%macro .idtentry 3
dw ((BASE_OF_SECTION + %1 - $$) & 0xFFFF) - 1024 	; low word bits (0-15) of offset
dw %2 												; code-segment-selector
db 0 												; always zero
db %3 												; type and Attributes
dw ((BASE_OF_SECTION + %1 - $$) >> 16) & 0xFFFF 	; middle bits (16-31) of offset
dd ((BASE_OF_SECTION + %1 - $$) >> 32) & 0xFFFFFFFF ; high bits (32-64) of offset
dd 0 												; reserved
%endmacro

IDT_START:
	; IDT Entry: Address of Interrupt Service Routine, Code Segment Selector, Attributes ;
	.idtentry ISR_division_by_zero	, CODE_SEG, 0x8f ; 0 (Division by zero)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 1 (Debug Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 2 (NMI, Non-Maskable Interrupt)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 3 (Breakpoint Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 4 (INTO Overflow)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 5 (Out of Bounds)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 6 (Invalid Opcode)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 7 (Device Not Available)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 8 (Double Fault)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 9 (Deprecated)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 10 (Invalid TSS)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 11 (Segment Not Present)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 12 (Stack-Segment Fault)
	.idtentry ISR_gpf 				, CODE_SEG, 0x8f ; 13 (General Protection Fault)
	.idtentry ISR_page_fault 		, CODE_SEG, 0x8f ; 14 (Page Fault)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 15 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 16 (x87 Floating-Point Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 17 (Alignment Check Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 18 (Machine Check Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 19 (SIMD Floating-Point Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 20 (Virtualization Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 21 (Control Protection Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 22 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 23 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 24 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 25 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 26 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 27 (Reserved)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 28 (Hypervisor Injection Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 29 (VMM Communication Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 30 (Security Exception)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 31 (Reserved)
	.idtentry ISR_systimer 			, CODE_SEG, 0x8f ; 32 (IRQ0: Programmable Interval Timer)
	.idtentry ISR_keyboard 			, CODE_SEG, 0x8e ; 33 (IRQ1: Keyboard)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 34 (IRQ2: PIC Cascade, used internally)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 35 (IRQ3: COM2, if enabled)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 36 (IRQ4: COM1, if enabled)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 37 (IRQ5: LPT2, if enabled)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 38 (IRQ6: Floppy Disk)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 39 (IRQ7: LPT1)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 40 (IRQ8: CMOS real-time clock)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 41 (IRQ9: Free)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 42 (IRQ10: Free)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 43 (IRQ11: Free)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 44 (IRQ12: PS2 Mouse)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 45 (IRQ13: Coprocessor)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 46 (IRQ14: Primary ATA Hard Disk)
	.idtentry ISR_dummy 			, CODE_SEG, 0x8f ; 47 (IRQ15: Secondary ATA Hard Disk)
; ...
; These are not all 256 entries. Accessing a missing entry will generate a
; General Protection Fault.
IDT_END:

; IDTR is the argument for the LIDT assembly instruction  which loads the
; location of the IDT to the IDT Register.
align 4
IDTR:
	.length dw IDT_END-IDT_START-1 	; One less than the size of the IDT in bytes.
	.base   dd IDT_START 			; The linear address of the Interrupt Descriptor Table
									; (not the physical address, paging applies)
