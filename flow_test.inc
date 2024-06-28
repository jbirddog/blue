
flow_test:
	call	data_stack_init

	t 'b, has the expected flow in'

	call	code_buffer_init
	
	mov	eax, 0x3c
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.b_comma
	call	flow_in

	mov	rsi, b_comma_flow_in
	mov	ecx, b_comma_flow_in.length
	call	check_code_buffer
	
	call	code_buffer_deinit

	ok

	t 'd, has the expected flow in'

	call	code_buffer_init
	
	mov	eax, 0x3c
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.d_comma
	call	flow_in

	mov	rsi, d_comma_flow_in
	mov	ecx, d_comma_flow_in.length
	call	check_code_buffer
	
	call	code_buffer_deinit

	ok
	
	t ': has the expected flow in'

	call	code_buffer_init
	
	mov	rax, _core_words.colon
	call	flow_in

	mov	rsi, nothing
	xor	ecx, ecx
	call	check_code_buffer
	
	call	code_buffer_deinit

	ok

	call	data_stack_deinit

	ret

b_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - b_comma_flow_in

d_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - d_comma_flow_in
