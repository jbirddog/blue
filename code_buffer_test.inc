
code_buffer_test:
	call	code_buffer_init

	t 'it inits base and here correctly'

	mov	rax, [_code_buffer.base]
	cmp	rax, [_code_buffer.here]
	jne	failure

	ok

	call code_buffer_deinit

	ret
;
; expects
;	- expected value in rsi
;	- expected length in ecx
;
check_code_buffer:
	mov	rdi, [_code_buffer.here]
	sub	rdi, [_code_buffer.base]

	cmp	edi, ecx
	jne	.failure_length
	
	mov	rdi, [_code_buffer.base]
	
	.loop:
	dec	ecx
	js	.done

	cmpsb
	jne	.failure_byte

	jmp	.loop

	.done:
	ret

	.failure_length:
	.failure_byte:

	call	dump_code_buffer
	jmp	failure

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

