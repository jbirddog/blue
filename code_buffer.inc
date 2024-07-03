		
code_buffer_init:
	mov	esi, _code_buffer.length
	mov	edx, PROT_RWX
	call	mmap_buffer
	
	mov 	rdi, _code_buffer.base
	stosq
	stosq
	
	ret

code_buffer_deinit:
	mov	esi, _code_buffer.length
	mov	rdi, [_code_buffer.base]
	mov	eax, SYS_MUNMAP
	ret
