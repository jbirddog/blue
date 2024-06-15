format elf64 executable 3

include "elf.inc"

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
	mov eax, program_code.entry_offset
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
