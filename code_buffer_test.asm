format elf64 executable 3

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "code_buffer.inc"

entry $
	call	code_buffer_init
	
	mov	edi, 1
	mov	rax, [_code_buffer.base]
	cmp	rax, [_code_buffer.here]
	jne	exit

	mov	al, 123
	call	_core_code.b_comma
	
	mov	edi, 2
	mov	rax, [_code_buffer.base]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 1
	jne	exit

	mov	edi, 3
	mov	rax, [rax]
	cmp	al, 123
	jne	exit

	mov	eax, 123456
	call	_core_code.d_comma

	mov	edi, 4
	mov	rax, [_code_buffer.base]
	inc	rax
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 4
	jne	exit

	mov	edi, 5
	mov	rax, [rax]
	cmp	eax, 123456
	jne	exit

	call code_buffer_deinit

	xor 	edi, edi

exit:
	mov eax, 60
	syscall
	ret
