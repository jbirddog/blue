
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

_at_inc_pre:
	call	data_stack_pop
	mov	rsi, rax
	xor	eax, eax

	ret

_at_inc_post:
	call	data_stack_push
	mov	rax, rsi
	call	data_stack_push

	ret

op_comp:
	; TODO: only need to do this if nested
	mov	rdi, [code_buffer_here]
	mov	al, op_lit_code
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
	mov	al, op_lit_code
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

macro begin_op lbl, size, flags
latest_op = lbl
latest_op_code = ($ - opcode_tbl) shr 4
lbl##_code = latest_op_code
	db flags, size
end macro

macro opN lbl, size, flags
__opN_##lbl:
	begin_op lbl, size, flags

	dq lbl
	dw 0
	dd 0
	
	assert ($ - __opN_##lbl) = (CELL_SIZE * 2)
end macro

macro opNI lbl, size, flags
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_INLINED
.impl:
end macro

macro opBI lbl, size, flags
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_BYTECODE or OPCODE_ENTRY_FLAG_INLINED
end macro

macro end_op
	assert ($ - latest_op) <= (CELL_SIZE * 2)
	times ((CELL_SIZE * 2) - ($ - latest_op)) db 0
	assert ($ - latest_op) = (CELL_SIZE * 2)
end macro

opcode_tbl:

opNI	op_exit, 1, 0	;	( b -- )	Exit with status from top of stack
	call	data_stack_pop
	mov	edi, eax
	jmp	exit
end_op

opNI	op_true, 1, 0	;	( -- t )	Push true value
	xor	eax, eax
	not	rax
	call	data_stack_push

	ret
end_op

opBI	op_false, 1, 0	;	( -- f )	Push false value
	db op_true_code, op_not_code, op_ret_code
end_op

opN	op_ifelse, 1, 0	;	( t/f ta fa -- ? )	Call ta if t/f is true else call fa

opNI	op_mccall, 1, 0	;	( a -- ? )	Call machine code at address
	call	data_stack_pop
	call	rax

	ret
end_op

opNI	op_call, 1, 0	;	( a -- ? )	Call bytecode located at address
	call	data_stack_pop
	call	_call

	ret
end_op

opNI	op_tor, 1, 0	;	( a -- )	Move top of data stack to return stack
	call	data_stack_pop
	call	return_stack_push

	ret
end_op

opNI	op_fromr, 1, 0	;	( -- a )	Move top of return stacl to data stack
	call	return_stack_pop
	call	data_stack_push

	ret
end_op

opNI	op_ret, 1, 0	;	( -- )	Pops value from return stack and sets the instruction pointer
	call	return_stack_pop
	mov	[instruction_pointer], rax
	
	ret
end_op

opN	op_comp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- )	Begin compiling bytecode
opN	op_endcomp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- a )	Append ret and end compilation, push addr where compilation started

opNI	op_ip, 1, 0	;	( -- a )	Push location of the instruction pointer
	mov	rax, [instruction_pointer]
	call	data_stack_push

	ret
end_op

opNI	op_setip, 1, 0	;	( a -- )	Sets the location of the instruction pointer
	call	data_stack_pop
	mov	[instruction_pointer], rax

	ret
end_op

opN	op_entry, 1, 0	;	( b -- a )	Push addr of the code for opcode

opNI	op_start, 1, 0	;	( -- a )	Push addr of the code buffer's start
	mov	rax, code_buffer
	call	data_stack_push
	
	ret
end_op
	
opNI	op_here, 1, 0	;	( -- a )	Push addr of the code buffer's here
	mov	rax, [code_buffer_here]
	call	data_stack_push

	ret
end_op

opNI	op_sethere, 1, 0	;	( a -- )	Set addr of the code buffer's here
	call	data_stack_pop
	mov	[code_buffer_here], rax

	ret
end_op

opNI	op_b_at_inc, 1, 0
	call	_at_inc_pre
	lodsb

	jmp	_at_inc_post
end_op

opNI	op_w_at_inc, 1, 0
	call	_at_inc_pre
	lodsw

	jmp	_at_inc_post
end_op

opNI	op_d_at_inc, 1, 0
	call	_at_inc_pre
	lodsd

	jmp	_at_inc_post
end_op

opNI	op_at_inc, 1, 0
	call	_at_inc_pre
	lodsq

	jmp	_at_inc_post
end_op

opBI	op_b_at, 1, 0
	db op_b_at_inc_code, op_drop_code, op_ret_code
end_op

opBI	op_w_at, 1, 0
	db op_w_at_inc_code, op_drop_code, op_ret_code
end_op

opBI	op_d_at, 1, 0
	db op_d_at_inc_code, op_drop_code, op_ret_code
end_op
	
opBI	op_at, 1, 0
	db op_at_inc_code, op_drop_code, op_ret_code
end_op	

opNI	op_b_set_inc, 1, 0
	call 	_set_pre
	stosb

	jmp	_set_post
end_op

opNI	op_w_set_inc, 1, 0
	call 	_set_pre
	stosw

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
	db op_here_code, op_swap_code, op_b_set_inc_code, op_sethere_code, op_ret_code
end_op

opBI	op_w_comma, 1, 0
	db op_here_code, op_swap_code, op_w_set_inc_code, op_sethere_code, op_ret_code
end_op

opBI	op_d_comma, 1, 0
	db op_here_code, op_swap_code, op_d_set_inc_code, op_sethere_code, op_ret_code
end_op

opBI	op_comma, 1, 0
	db op_here_code, op_swap_code, op_set_inc_code, op_sethere_code, op_ret_code
end_op

opNI	op_litb, 2, 0
	call	_pre_lit
	lodsb

	jmp	_post_lit
end_op

opNI	op_litw, 3, 0
	call	_pre_lit
	lodsw

	jmp	_post_lit
end_op

opNI	op_litd, 5, 0
	call	_pre_lit
	lodsd

	jmp	_post_lit
end_op

opNI	op_lit, 9, 0
	call	_pre_lit
	lodsq

	jmp	_post_lit
end_op

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
	call	data_stack_pop2a
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

opNI	op_sub, 1, 0
	call	data_stack_pop2a
	sub	rax, rcx
	call	data_stack_push

	ret
end_op

opNI	op_shl, 1, 0
	call	data_stack_pop2a
	shl	rax, cl
	call	data_stack_push

	ret
end_op

opNI	op_shr, 1, 0
	call	data_stack_pop2a
	shr	rax, cl
	call	data_stack_push

	ret
end_op


assert (($ - opcode_tbl) and 0x07) = 0
assert ($ - opcode_tbl) <= VM_OPCODE_TBL_SIZE

