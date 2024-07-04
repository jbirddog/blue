
dump_code_buffer:
	mov	rdi, _code_buffer_dump_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, [_code_buffer.base]
	mov	rdx, [_code_buffer.here]
	sub	rdx, rsi
	mov	eax, SYS_WRITE
	syscall
	
	mov	eax, SYS_CLOSE
	syscall
	
	ret

_code_buffer_dump_file:
	db	"code_buffer_dump.out"
	db	0x00
