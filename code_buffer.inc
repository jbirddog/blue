
code_buffer_init:
	macro _init cb {
		mov	esi, cb##.length
		mov	edx, PROT_RWX
		call	mmap_buffer
	
		mov 	rdi, cb##.base
		stosq
		stosq
	}

	_init	_code_buffer
	_init	_code_buffer_interpret
	
	ret

code_buffer_deinit:
	macro _deinit cb {
		mov	esi, cb##.length
		mov	rdi, [cb##.base]
		mov	eax, SYS_MUNMAP
	}

	_deinit	_code_buffer
	_deinit	_code_buffer_interpret
	
	ret
