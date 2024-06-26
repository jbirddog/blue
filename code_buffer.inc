
_core_code:
	.b_comma:
	mov	rdi, [_code_buffer.here]
	stosb
	mov	[_code_buffer.here], rdi
	ret

	.b_comma2:
	mov edi, eax
	mov eax, 60
	syscall
	ret
	
	.d_comma:
	mov	rdi, [_code_buffer.here]
	stosd
	mov	[_code_buffer.here], rdi
	ret
	
	.q_comma:
	mov	rdi, [_code_buffer.here]
	stosq
	mov	[_code_buffer.here], rdi
	ret
	
code_buffer_init:
	mov	esi, _code_buffer.length
	mov	edx, PROT_RWX
	call	mmap_buffer
	
	mov 	rdi, _code_buffer.base
	stosq
	stosq

	xor	eax, eax
	stosq
	stosd
	
	ret

code_buffer_deinit:
	mov	esi, _code_buffer.length
	mov	rdi, [_code_buffer.base]
	mov	eax, SYS_MUNMAP
	ret
