format elf64 executable 3

include "linux.inc"
include "elf.inc"

segment readable writeable

program_code:
	.entry_offset = $ - program_code
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

segment readable executable

entry $	
	mov	eax, program_code.entry_offset
	mov	ecx, program_code.length
	call	elf_binary_calculate_fields

	mov	edi, 1
	cmp	qword [elf_header.start_address], 0x400078
	jne	exit

	mov	edi, 2
	cmp	qword [elf_header.section_header_offset], 0xc0
	jne	exit

	;
	; exit cleanly
	;
	xor 	edi, edi

exit:
	mov 	eax, SYS_EXIT
	syscall
