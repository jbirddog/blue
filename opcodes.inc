
_call:
	xchg	[instruction_pointer], rax
	call	return_stack_push

	ret

op_if_else:
	call	data_stack_pop2
	push	rax
	call	data_stack_pop
	pop	rdx
	
	test	rax, rax
	cmovz	rax, rdx
	cmovnz	rax, rcx
	
	call	_call

	ret

op_entry:
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
	
op_sub:
	call	data_stack_pop2
	xchg	rax, rcx	
	sub	rax, rcx
	call	data_stack_push

	ret

op_b_at:
	call	data_stack_pop
	mov	rsi, rax
	xor	eax, eax
	lodsb
	call	data_stack_push

	ret

op_compile_begin:
	; TODO: only need to do this if nested
	mov	rdi, [code_buffer_here]
	mov	al, op_lit_code
	stosb
	push	rdi
	xor	eax, eax
	stosq
	mov	al, op_set_ip_code
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

op_compile_end:
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
	mov	al, op_lit_code
	stosb
	pop	rax
	stosq
	mov	[code_buffer_here], rdi
	
	ret

.outer:
	call	op_from_r.impl
	
	ret
	
_set_pre:
	call	data_stack_pop2
	mov	rdi, rcx

	ret

_set_post:
	mov	rax, rdi
	call	data_stack_push

	ret

op_lit:
	mov	rsi, [instruction_pointer]
	lodsq
	mov	[instruction_pointer], rsi

	call	data_stack_push

	ret

macro begin_op lbl, size, flags {
latest_op = lbl
latest_op_code = ($ - opcode_tbl) shr 4
lbl##_code = latest_op_code
	db flags, size
}

macro opN lbl, size, flags {
__opN_##lbl:
	begin_op lbl, size, flags

	dq lbl
	dw 0
	dd 0
	
	assert ($ - __opN_##lbl) = (CELL_SIZE * 2)
}

macro opNI lbl, size, flags {
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_INLINED
.impl:
}

macro opBI lbl, size, flags {
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_BYTECODE or OPCODE_ENTRY_FLAG_INLINED
}

macro end_op {
	assert ($ - latest_op) <= (CELL_SIZE * 2)
	times ((CELL_SIZE * 2) - ($ - latest_op)) db 0
	assert ($ - latest_op) = (CELL_SIZE * 2)
}

opcode_tbl:

opNI	op_exit, 1, 0
	call	data_stack_pop
	mov	edi, eax
	jmp	exit
end_op

opNI	op_true, 1, 0
	xor	eax, eax
	not	rax
	call	data_stack_push

	ret
end_op

opBI	op_false, 1, 0
	db op_true_code, op_not_code, op_ret_code
end_op

opN	op_if_else, 1, 0

opNI	op_mccall, 1, 0
	call	data_stack_pop
	call	rax

	ret
end_op

opNI	op_call, 1, 0
	call	data_stack_pop
	call	_call

	ret
end_op

opNI	op_to_r, 1, 0
	call	data_stack_pop
	call	return_stack_push

	ret
end_op

opNI	op_from_r, 1, 0
	call	return_stack_pop
	call	data_stack_push

	ret
end_op

opNI	op_ret, 1, 0
	call	return_stack_pop
	mov	[instruction_pointer], rax
	
	ret
end_op

opN	op_compile_begin, 1, OPCODE_ENTRY_FLAG_IMMEDIATE
opN	op_compile_end, 1, OPCODE_ENTRY_FLAG_IMMEDIATE

opNI	op_ip, 1, 0
	mov	rax, [instruction_pointer]
	call	data_stack_push

	ret
end_op

opNI	op_set_ip, 1, 0
	call	data_stack_pop
	mov	[instruction_pointer], rax

	ret
end_op

opN	op_entry, 1, 0

opNI	op_start, 1, 0
	mov	rax, code_buffer
	call	data_stack_push
	
	ret
end_op
	
opNI	op_here, 1, 0
	mov	rax, [code_buffer_here]
	call	data_stack_push

	ret
end_op

opNI	op_set_here, 1, 0
	call	data_stack_pop
	mov	[code_buffer_here], rax

	ret
end_op

opN	op_b_at, 1, 0
	
opNI	op_at, 1, 0
	call	data_stack_pop
	mov	rax, [rax]
	call	data_stack_push

	ret
end_op	

opNI	op_b_set_inc, 1, 0
	call 	_set_pre
	stosb

	jmp	_set_post
end_op

opNI	op_d_set_inc, 1, 0
	call 	_set_pre
	stosd

	jmp	_set_post
end_op
	

opNI	op_set_inc, 1, 0
	call 	_set_pre
	stosq

	jmp	_set_post
end_op

opBI	op_b_comma, 1, 0
	db op_here_code, op_swap_code, op_b_set_inc_code, op_set_here_code, op_ret_code
end_op

opBI	op_d_comma, 1, 0
	db op_here_code, op_swap_code, op_d_set_inc_code, op_set_here_code, op_ret_code
end_op

opBI	op_comma, 1, 0
	db op_here_code, op_swap_code, op_set_inc_code, op_set_here_code, op_ret_code
end_op

opNI	op_litb, 2, 0
	call	read_byte
	call	data_stack_push
	
	ret
end_op

opN	op_lit, 9, 0

;
; stack ops
;

opNI	op_depth, 1, 0
	call	data_stack_depth
	mov	eax, ecx
	call	data_stack_push
	
	ret
end_op

opNI	op_dup, 1, 0
	call	data_stack_pop
	mov	rcx, rax
	call	data_stack_push2

	ret
end_op

opNI	op_drop, 1, 0
	call	data_stack_pop
	ret
end_op

opNI	op_swap, 1, 0
	call	data_stack_pop2
	xchg	rax, rcx
	call	data_stack_push2

	ret
end_op

opNI	op_not, 1, 0
	call	data_stack_pop
	not	rax
	call	data_stack_push
	
	ret
end_op

opN	op_eq, 1, 0

opNI	op_add, 1, 0
	call	data_stack_pop2
	add	rax, rcx
	call	data_stack_push

	ret
end_op

opN	op_sub, 1, 0


assert (($ - opcode_tbl) and 0x07) = 0
assert ($ - opcode_tbl) <= (0x7F shl 4)
assert ($ - opcode_tbl) <= OPCODE_TBL_SIZE

