bits 16

%define PAGE_PRESENT (1 << 0)
%define PAGE_WRITE   (1 << 1)
%define CODE_SEG      0x0008
%define PAGING_DATA   0x9000

; initialised data
gdt:
; The Global Descriptor Table (GDT) is a data structure used by x86-family
; processors (starting with the 80286) in order to define the characteristics of
; the various memory areas (segments) used during program execution, including
; the base address, the size, and access privileges like executability and
; writability.
; The GDT is still present in 64-bit mode; a GDT must be defined, but is
; generally never changed or used for segmentation.
;
; https://en.wikipedia.org/wiki/Global_Descriptor_Table
	.null:
		; null descriptor (should be present)
		dq 0x0000000000000000
	.code:
		; 64-bit code descriptor (exec/read)
		dq 0x00209a0000000000
		; 64-bit data descriptor (read/write)
		dq 0x0000920000000000
		align 4
		; padding (to make the "address of the GDT" field aligned on a 4-byte
		; boundary)
		dw 0
	.pointer:
		; 16-bit Size (Limit) of GDT
		dw $ - gdt - 1
		; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)
		dd gdt

prepare_paging:
; es:edi should point to a valid page-aligned 16KiB buffer, for the PML4, PDPT,
;        PD and a PT
; ss:esp should point to memory that can be used as a small (1 uint32_t) stack
;
; The Memory Management Unit (MMU) uses this table to map virtual memory to
; physical memory.
;
	; point edi to a free space to create the paging structures
	; TODO: When a "bigger" kernel is loaded 0x8000 might not be the best place
	;       to put the paging tables.
	mov edi, PAGING_DATA

	; zero out the 16KiB buffer. Since we are doing a rep stosd, count should be
	; bytes/4.
	push di ; 'rep stosd' alters di
	mov ecx, 0x1000
	xor eax, eax
	cld
	rep stosd
	pop di ; get di back

	; build the page map level 4. ed:di points to the page map level 4 table.
	lea eax, [es:di + 0x1000]         ; eax = address of the page directory pointer table
	or eax, PAGE_PRESENT | PAGE_WRITE ; or eax with the flags (present flag, writable flag)
	mov [es:di], eax                  ; store the value of eax as the first PML4E

	; build the page directory pointer table
	lea eax, [es:di + 0x2000]         ; put the address of the page directory in to eax
	or eax, PAGE_PRESENT | PAGE_WRITE ; or eax with the flags (present flag, writable flag)
	mov [es:di + 0x1000], eax         ; store the value of eax as the first PDPTE

	 ; Build the Page Directory.
	lea eax, [es:di + 0x3000]          ; put the address of the page table in to eax
	or eax, PAGE_PRESENT | PAGE_WRITE  ; or eax with the flags (present flag, writable flag)
	mov [es:di + 0x2000], eax          ; store to value of eax as the first PDE

	push di                            ; save DI for the time being
	lea di, [di + 0x3000]              ; point DI to the page table
	mov eax, PAGE_PRESENT | PAGE_WRITE ; move the flags into eax - and point it to 0x0000

	; build the page table
	.loop_page_table:
		mov [es:di], eax
		add eax, 0x1000
		add di, 8
		; if we did all 2 MiB, end
		cmp eax, 0x200000
		jb .loop_page_table

	pop di ; restore di
	ret
