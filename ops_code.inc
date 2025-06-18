
_call:
	xchg	IP_REG, rax
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

op_opentry:
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

	mov	OP_REG, opcode_handler_compile

	pop	rax
	call	return_stack_push
	
	ret

op_endcomp:
	mov	rdi, [code_buffer_here]
	mov	al, op_ret_code
	stosb
	mov	[code_buffer_here], rdi

	; patch the addr for setip that was compiled in before the compilation
	call	return_stack_pop
	mov	[rax], rdi

	mov	OP_REG, opcode_handler_interpret
	
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

_post_lit:
	call	data_stack_push
	mov	IP_REG, rsi

	ret

_syscall6:
	mov	r9, [DS_REG - (CELL_SIZE * 7)]

_syscall5:
	mov	r8, [DS_REG - (CELL_SIZE * 6)]
	
_syscall4:
	mov	r10, [DS_REG - (CELL_SIZE * 5)]
	
_syscall3:
	mov	rdx, [DS_REG - (CELL_SIZE * 4)]
	
_syscall2:
	mov	rsi, [DS_REG - (CELL_SIZE * 3)]
	
_syscall1:
	mov	rdi, [DS_REG - (CELL_SIZE * 2)]

_syscall0:
	mov	rax, [DS_REG - CELL_SIZE]
	syscall
	
	pop	rcx
	sub	DS_REG, rcx
	mov	[DS_REG - CELL_SIZE], rax
	
	ret
