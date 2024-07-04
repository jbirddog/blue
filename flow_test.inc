
macro tc1 what, lit {
	t 'has the expected flow in'
	
	call	code_buffer_init
	call	data_stack_init

	mov	eax, lit
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.##what
	call	flow_in

	mov	rsi, what##_flow_in
	mov	ecx, what##_flow_in.length
	call	check_code_buffer
	
	call	data_stack_deinit
	call	code_buffer_deinit

	ok
}

macro tc2 what {
	t 'has the expected flow in'

	call	code_buffer_init
	call	data_stack_init
	
	mov	rax, _core_words.##what
	call	flow_in

	mov	rsi, nothing
	xor	ecx, ecx
	call	check_code_buffer
	
	call	data_stack_deinit
	call	code_buffer_deinit

	ok
}

flow_test:
		
	tc1	b_comma, 0x3c
	tc1	d_comma, 0x3c
	tc1	q_comma, 0x3c
	tc1	base, 0x10
	tc2	colon

	ret

b_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - b_comma_flow_in

d_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - d_comma_flow_in

q_comma_flow_in:
	db	0xb8
	dd	0x3c
	.length = $ - q_comma_flow_in

base_flow_in:
	db	0xb8
	dd	0x10
	.length = $ - base_flow_in
