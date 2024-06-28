
flow_test:
	call	code_buffer_init
	call	data_stack_init

	t 'b, has the expected flow in'
	
	mov	eax, 0x3c
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.b_comma
	call	flow_in

	mov	rsi, flow_1
	mov	ecx, flow_1.length
	call	check_code_buffer

	ok
	
	call	code_buffer_deinit
	call	data_stack_deinit

	ret

flow_1:
	db	0xb8
	dd	0x3c
	.length = $ - flow_1
