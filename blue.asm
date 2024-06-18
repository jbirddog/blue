format elf64 executable 3

include "elf.inc"

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "code_buffer.inc"

output_file:
	db	"a.out"
	db	0x00

_simulate_compilation:
	xor	eax, eax

	; xor edi, edi
	mov	al, 0x31
	call	_core_code.b_comma
	mov	al, 0xff
	call	_core_code.b_comma	

	; mov eax, 60
	mov	al, 0xb8
	call	_core_code.b_comma
	mov	eax, 0x3c
	call	_core_code.d_comma

	; syscall
	mov	al, 0x0f
	call	_core_code.b_comma
	mov	al, 0x05
	call	_core_code.b_comma
	
	ret

entry $
	call code_buffer_init

	call _simulate_compilation

	;
	; write the output to ./a.out
	;
	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, [_code_buffer.base]
	mov	eax, [_code_buffer.entry]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rsi
	call	elf_binary_write
	
	mov	eax, SYS_CLOSE
	syscall

	call code_buffer_deinit

	;
	; exit cleanly
	;
	xor 	edi, edi
	mov 	eax, SYS_EXIT
	syscall
