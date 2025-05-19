
_call:
	xchg	[instruction_pointer], rax
	call	return_stack_push

	ret

op_ifelse:
	call	data_stack_pop2
	push	rax
	call	data_stack_pop
	pop	rdx
	
	test	rax, rax
	cmovz	rax, rdx
	cmovnz	rax, rcx
	
	call	_call

	ret

op_op:
	call	data_stack_pop
	shl	eax, 4
	add	rax, opcode_tbl
	call	data_stack_push

	ret
	
op_eq:
	call	data_stack_pop2
	mov	rdx, rax
	xor	eax, eax

	cmp	rdx, rcx
	jne	.push
	not	rax

.push:
	call	data_stack_push

	ret

_atinc_pre:
	call	data_stack_pop
	mov	rsi, rax
	xor	eax, eax

	ret

_atinc_post:
	call	data_stack_push
	mov	rax, rsi
	call	data_stack_push

	ret

op_comp:
	; TODO: only need to do this if nested
	mov	rdi, [code_buffer_here]
	mov	al, op_litq_code
	stosb
	push	rdi
	xor	eax, eax
	stosq
	mov	al, op_setip_code
	stosb
	mov	[code_buffer_here], rdi

	mov	rax, rdi
	call	return_stack_push

	mov	rax, OPCODE_HANDLER_COMPILE
	xchg	[opcode_handler], rax
	call	return_stack_push

	pop	rax
	call	return_stack_push
	
	ret

op_endcomp:
	mov	rdi, [code_buffer_here]
	mov	al, op_ret_code
	stosb
	mov	[code_buffer_here], rdi

	; patch the addr for ip! that was compiled in before the compilation
	call	return_stack_pop
	mov	[rax], rdi

	call	return_stack_pop
	mov	[opcode_handler], rax

	cmp	rax, OPCODE_HANDLER_INTERPRET
	je	.outer
	
.nested:
	call	return_stack_pop
	push	rax
	
	mov	rdi, [code_buffer_here]
	mov	al, op_litq_code
	stosb
	pop	rax
	stosq
	mov	[code_buffer_here], rdi
	
	ret

.outer:
	call	op_fromr.impl
	
	ret
	
_set_pre:
	call	data_stack_pop2
	mov	rdi, rcx

	ret

_set_post:
	mov	rax, rdi
	call	data_stack_push

	ret

_pre_lit:
	mov	rsi, [instruction_pointer]
	xor	eax, eax

	ret

_post_lit:
	call	data_stack_push
	mov	[instruction_pointer], rsi

	ret
