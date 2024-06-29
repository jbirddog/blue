
flow_test:
	t 'b, has the expected flow in'
	
	call	code_buffer_init
	call	data_stack_init

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
	call	data_stack_deinit

	ok

	t 'base has the expected flow in'
	
	call	code_buffer_init
	call	data_stack_init

	mov	eax, 0x10
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.base
	call	flow_in

	mov	rsi, base_flow_in
	mov	ecx, base_flow_in.length
	call	check_code_buffer
	
	call	code_buffer_deinit
	call	data_stack_deinit

	ok

	ret

b_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - b_comma_flow_in

base_flow_in:
	db	0xb8
	dd	0x10
	.length = $ - base_flow_in
