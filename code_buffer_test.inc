
code_buffer_test:
	call	code_buffer_init

	t 'it inits correctly'

	mov	rax, [_code_buffer.base]
	cmp	rax, [_code_buffer.here]
	jne	failure

	cmp	[_code_buffer.mark], 0
	jne	failure

	cmp	[_code_buffer.entry], 0
	jne	failure

	ok

	t 'b, writes a byte'

	mov	al, 123
	call	_core_code.b_comma
	
	mov	rax, [_code_buffer.base]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 1
	jne	failure
	push	rax

	ok

	t 'b, writes the correct value'

	pop	rax
	mov	rax, [rax]
	cmp	al, 123
	jne	failure

	ok

	t 'd, writes a dword'
	
	mov	eax, 123456
	call	_core_code.d_comma

	mov	rax, [_code_buffer.base]
	inc	rax
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 4
	jne	failure
	push	rax

	ok

	t 'd, writes the correct value'

	pop	rax
	mov	rax, [rax]
	cmp	eax, 123456
	jne	failure

	ok

	call code_buffer_deinit

	ret