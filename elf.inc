
;
; expects
; 	- program code entry offset in eax
;	- program code length in ecx
;
elf_binary_calculate_fields:
	add	eax, elf_binary_headers_length
	push	rax
	add	eax, elf_binary.base_address
	mov	qword [elf_header.start_address], rax

	pop	rax
	mov	qword [program_code_section_header.offset], rax

	mov	edi, eax
	add	edi, elf_binary.base_address
	mov	qword [program_code_section_header.address], rdi
	
	mov	qword [program_code_section_header.size], rcx
	
	add	eax, ecx
	mov 	rdi, program_header.sizes
	stosq
	stosq

	mov	rdi, shstrtab_section_header.offset
	stosq

	mov	eax, shstrtab.length
	stosq

	add	ecx, elf_binary_section_headers_offset
	mov	qword [elf_header.section_header_offset], rcx

	ret
;
; expects
;	- program code start in rsi
; 	- program code entry offset in eax
;	- program code length in ecx
;	- file descriptor in edi
;
elf_binary_write:
	push	rsi
	push	rcx
	push	rdi
	call	elf_binary_calculate_fields
	pop	rdi

	mov	rsi, elf_binary_headers
	mov	rdx, elf_binary_headers_length
	mov	eax, SYS_WRITE
	syscall

	pop	rcx
	pop	rsi
	mov	edx, ecx
	mov	eax, SYS_WRITE
	syscall

	mov	rsi, shstrtab
	mov	rdx, shstrtab.length
	mov	eax, SYS_WRITE
	syscall

	mov	rsi, elf_binary_section_headers
	mov	rdx, elf_binary_section_headers_length
	mov	eax, SYS_WRITE
	syscall

	ret
