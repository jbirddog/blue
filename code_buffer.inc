
_core_code:
	.b_comma:
	mov rdi, [_code_buffer.here]
	stosb
	mov [_code_buffer.here], rdi
	
	.d_comma:
	mov rdi, [_code_buffer.here]
	stosd
	mov [_code_buffer.here], rdi
	ret
	ret

code_buffer:
	.init:
	mmap_buffer _code_buffer.length, PROT_RWX
	
	mov [_code_buffer.base], rax
	mov [_code_buffer.here], rax
	ret

	.deinit:
	mov esi, _code_buffer.length
	mov rdi, [_code_buffer.base]
	call mmap.unmap
	ret
