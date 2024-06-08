
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
