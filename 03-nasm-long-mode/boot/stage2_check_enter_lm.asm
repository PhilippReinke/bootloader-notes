bits 16

is_longmode_supported:
; check if long mode is supported
; returns eax = 0 if long mode is not supported, otherwise non-zero

	; test if extended processor info in available
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb .not_supported

	; after calling CPUID with eax = 0x80000001,
	; all AMD64 compliant processors have the longmode-capable-bit
	; (bit 29) turned on in the edx (extended feature flags).
	mov eax, 0x80000001
	cpuid
	test edx, (1 << 29)

	; if it's not set, there is no long mode
	jz .not_supported
	ret

	.not_supported:
	xor eax, eax
	ret

enter_long_mode:
	; point edi at the PAGING_DATA
	mov edi, PAGING_DATA

	; set the PAE and PGE bit
	mov eax, 10100000b
	mov cr4, eax

	; point CR3 at the PML4
	mov edx, edi
	mov cr3, edx

	; read from the EFER MSR
	mov ecx, 0xC0000080
	rdmsr

	; set the LME bit
	or eax, 0x00000100
	wrmsr

	; activate long mode by enabling paging and
	; protection simultaneously
	mov ebx, cr0
	or ebx, 0x80000001
	mov cr0, ebx

	; load gdt.pointer
	lgdt [gdt.pointer]

	; load CS with 64 bit segment and flush the instruction cache
	jmp CODE_SEG:stage3_entry
