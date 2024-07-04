
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
	jl	.failure_length
	
	mov	rdi, [_code_buffer.here]
	sub	rdi, rcx
	
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

