
code_buffer_test:
	call	code_buffer_init

	t 'it inits base and here correctly'

	mov	rax, [_code_buffer.base]
	cmp	rax, [_code_buffer.here]
	jne	failure

	ok

	t 'it inits mark correctly'

	cmp	[_code_buffer.mark], 0
	jne	failure

	ok

	t 'it inits entry correctly'
	
	cmp	[_code_buffer.entry], 0
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
	jmp	failure

	.failure_byte:
	jmp	failure
