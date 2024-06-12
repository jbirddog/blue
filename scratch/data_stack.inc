
data_stack:
	.init:
	mmap_buffer _data_stack.length, PROT_RW
	
	mov [_data_stack.base], rax
	mov [_data_stack.here], rax
	ret

	.deinit:
	mov esi, _data_stack.length
	mov rdi, [_data_stack.base]
	call mmap.unmap
	ret
	
	.push:
	mov rdi, [_data_stack.here]
	stosq
	mov [_data_stack.here], rdi
	ret

	.pop:
	mov rsi, [_data_stack.here]
	cmp rsi, [_data_stack.base]
	jle .underflow
	std
	lodsq
	mov [_data_stack.here], rsi
	lodsq
	cld
	ret

	.underflow:
	mov edi, 3
	mov eax, 60
	syscall

	.depth:
	mov rax, [_data_stack.here]
	sub rax, [_data_stack.base]
	shr rax, 3
	ret

