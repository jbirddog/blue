
data_stack_init:
	mov	esi, _data_stack.length
	mov	edx, PROT_RW
	call	mmap_buffer
	
	mov	rdi, _data_stack.base
	stosq
	stosq
	ret

data_stack_deinit:
	mov	esi, _data_stack.length
	mov	rdi, [_data_stack.base]
	mov	eax, SYS_MUNMAP
	syscall
	ret

;
; expects
;	- value to push in rax
;
data_stack_push:
	mov	rdi, [_data_stack.here]
	stosq
	mov	[_data_stack.here], rdi
	ret

data_stack_pop:
	mov	rsi, [_data_stack.here]
	cmp	rsi, [_data_stack.base]
	jle	.underflow
	
	std
	lodsq
	mov	[_data_stack.here], rsi
	lodsq
	cld
	
	ret
	
	.underflow:
	die	ERR_UNDERFLOW

data_stack_depth:
	mov	rax, [_data_stack.here]
	sub	rax, [_data_stack.base]
	shr	rax, 3
	ret

