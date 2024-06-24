format elf64 executable 3

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "data_stack.inc"

entry $
	call	data_stack_init
	xor	edi, edi
	
	inc	edi
	call	data_stack_depth
	test	eax, eax
	jnz	exit

	inc	edi
	mov	eax, 5
	call	data_stack_push

	call	data_stack_depth
	cmp	eax, 1
	jne	exit

	call	data_stack_pop
	cmp	eax, 5
	jne	exit

	call	data_stack_depth
	test	eax, eax
	jnz	exit

	inc	edi
	mov	eax, 7
	call	data_stack_push
	mov	eax, 9
	call	data_stack_push

	xor	eax, eax
	call	data_stack_pop

	cmp	eax, 9
	jne	exit

	mov	eax, 11
	call	data_stack_push

	call	data_stack_depth
	cmp	eax, 2
	jne	exit

	call	data_stack_pop
	call	data_stack_pop

	cmp	eax, 7
	jne	exit

	call	data_stack_depth
	test	eax, eax
	jnz	exit

	call data_stack_deinit

	xor edi, edi

exit:
	mov eax, 60
	syscall
	ret
