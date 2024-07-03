
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
	jne	failure
	
	mov	rdi, [_code_buffer.base]
	
	.loop:
	dec	ecx
	js	.done

	cmpsb
	jne	failure

	jmp	.loop

	.done:
	ret
