format elf64 executable 3

segment readable writeable
	
;
; adapted from https://kevinboone.me/elfdemo.html
;

elf_binary:
elf_header:
	db	0x7f, 0x45, 0x4c, 0x46	; magic number
	db	0x02			; 64 bit
	db	0x01			; little endian
	db	0x01			; elf version
	db	0x00			; target abi	
	dq	0x00			; target abi version + 7 bytes undefined
	dw	0x02			; executable binary
	dw	0x3e			; amd64 architecture
	dd	0x01			; elf version
	dq	0x400078		; start address
	dq	0x40			; offset to program header
	.section_header_offset:
	dq	0x00			; offset to section header
	dd	0x00			; architecture flags
	dw	0x40			; size of header
	dw	0x38			; size of program header
	dw	0x01			; number of program headers
	dw	0x40			; size of section header
	dw	0x03			; number of section headers
	dw	0x02			; index of strtab section header

	.length = $ - elf_header
	assert .length = 0x40

program_header:
	dd	0x01			; entry type: loadable segment
	dd	0x05			; segment flags: RX
	dq	0x00			; offset within file
	dq	0x400000		; load position in virtual memory
	dq	0x400000		; load position in physical memory
	.sizes:
	dq	0x00			; size of the loaded section (file)
	dq	0x00			; size of the loaded section (memory)
	dq	0x200000		; alignment boundary for sections

	.length = $ - program_header
	assert .length = 0x38

program_code:
	db	0x48, 0xc7, 0xc0	; mov rax, 1 - sys_write
	dd	0x01
	db	0x48, 0xc7, 0xc7	; mov rdi, 1 - stdout fd
	dd	0x01
	db	0x48, 0xc7, 0xc6	; mov rsi, 0x4000a2 - location of string
	dd	0x4000a2
	db	0x48, 0xc7, 0xc2	; mov rdx, 13 - size of string
	dd	0x0d
	db	0x0f, 0x05		; syscall
	db	0x48, 0xc7, 0xc0	; mov rax, 60 - sys_exit
	dd	0x3c
	db	0x48, 0x31, 0xff	; xor rdi, rdi
	db	0x0f, 0x05		; syscall

	db	"Hello, world"
	db	0x0a, 0x00

	.length = $ - program_code
	assert .length = 0x38
	assert $ - elf_header = 0xb0

shstrtab:
	db	".shstrtab"
	db	0x00
	db	".text"
	db	0x00

	.length = $ - shstrtab
	assert .length = 0x10

section_0:
	dq 	0x00, 0x00, 0x00, 0x00	; 64 bytes of 0s 
	dq 	0x00, 0x00, 0x00, 0x00

	.length = $ - section_0
	assert .length = 0x40

program_code_section_header:
	dd	0x0a			; offset to name in shstrtab
	dd 	0x01			; type: program data
	dq 	0x06			; flags - executable | in memory
	dq 	0x400078		; addr in virtual memory of section
	.offset:
	dq 	0x00			; offset in the file of this section
	.size:
	dq 	0x00			; size of this section in the file
	dq 	0x00			; sh_link - not used
	dq 	0x01			; alignment code (default??)
	dq 	0x00			; sh_entsize - not used

	.length = $ - program_code_section_header
	assert .length = 0x40

shstrtab_section_header:
	dd 	0x00			; offset to name in shstrtab
	dd 	0x03			; type: string table
	dq 	0x00			; flags - none
	dq 	0x00			; addr in virtual memory of section - not used
	.offset:
	dq 	0x00			; offset in the file of this section
	.size:
	dq 	0x00			; size of this section in the file
	dq 	0x00			; sh_link - not used
	dq 	0x01			; alignment code (default??)
	dq 	0x00			; sh_entsize - not used

	.length = $ - shstrtab_section_header
	assert .length = 0x40
	
elf_binary_length = $ - elf_binary

segment readable executable

;
; expects length of program code in ecx
;
elf_binary_calculate_fields:
	mov	eax, elf_header.length + program_header.length
	mov	qword [program_code_section_header.offset], rax
	mov	qword [program_code_section_header.size], rcx
	
	add	eax, ecx
	mov 	rdi, program_header.sizes
	stosq
	stosq

	mov	rdi, shstrtab_section_header.offset
	stosq

	mov	eax, shstrtab.length
	stosq

	add	ecx, elf_header.length + program_header.length
	mov	qword [elf_header.section_header_offset], rcx

	ret

;
; compiler entry point
;

segment readable executable

output_file:
	db	"a.out"
	db	0x00

SYS_WRITE = 1
SYS_OPEN = 2
SYS_CLOSE = 3
SYS_EXIT = 60

entry $
	mov ecx, program_code.length
	call elf_binary_calculate_fields
	
	;
	; write the output to ./a.out
	;
	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	push rax
	push rax

	mov	rdi, rax
	mov	rsi, elf_binary
	mov	rdx, elf_binary_length
	mov	eax, SYS_WRITE
	syscall

	pop	rdi
	mov	eax, SYS_CLOSE
	syscall

	;
	; exit cleanly
	;
	xor 	edi, edi
	mov 	eax, SYS_EXIT
	syscall
