
_call:
	mov	rax, [instruction_pointer]
	call	return_stack_push

	call	data_stack_pop
	mov	[instruction_pointer], rax

	ret

_call2:
	xchg	[instruction_pointer], rax
	call	return_stack_push

	ret


op_if:
	call	data_stack_pop2
	test	rcx, rcx
	jz	.done
	
	call	_call2

.done:
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

; TODO: replace with bytecode in host
op_assert:
	call	data_stack_pop
	mov	edi, eax
	not	edi
	test	edi, edi
	jnz	exit
	
	ret
	
op_sub:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	pop	rcx
	
	sub	rax, rcx
	call	data_stack_push

	ret

op_add:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	pop	rcx
	
	add	rax, rcx
	call	data_stack_push

	ret

op_b_at:
	call	data_stack_pop
	mov	rsi, rax
	xor	eax, eax
	lodsb
	call	data_stack_push

	ret

op_compile:
	call	op_here.impl
	call	op_to_r.impl
	mov	[opcode_handler], OPCODE_HANDLER_COMPILE
	
	ret

op_interpret:
	mov	rdi, [code_buffer_here]
	mov	al, op_ret_code
	stosb
	mov	[code_buffer_here], rdi

	mov	[opcode_handler], OPCODE_HANDLER_INTERPRET
	call	op_from_r.impl
	
	ret
	
_set_pre:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	mov	rdi, rax
	pop	rax

	ret

_set_post:
	mov	rax, rdi
	call	data_stack_push

	ret

macro begin_op lbl, size, flags {
latest_op = lbl
latest_op_code = ($ - _opcode_map) shr 4
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

_opcode_map:

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

opN	op_if, 1, 0

opNI	op_mccall, 1, 0
	call	data_stack_pop
	call	rax

	ret
end_op

opN	_call, 1, 0

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

opN	op_compile, 1, 0
opN	op_interpret, 1, OPCODE_ENTRY_FLAG_IMMEDIATE

opNI	op_start, 1, 0
	mov	rax, [code_buffer]
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
opN	op_add, 1, 0
opN	op_sub, 1, 0

opN	op_assert, 1, 0


assert (($ - _opcode_map) and 0x07) = 0
assert ($ - _opcode_map) <= (0x7F shl 4)


; expects opcode in rax
opcode_map_entry:
	mov	edx, eax
	shl	eax, 4
	
	mov	rsi, [opcode_map]
	add	rsi, rax
	mov	rcx, [rsi]
	
	test	rcx, rcx
	jnz	.continue

	cmp	edx, latest_op_code
	jg	.continue

	mov	rsi, _opcode_map
	add	rsi, rax
	mov	rcx, [rsi]

.continue:
	lea	rdi, [rsi + 2]
	
	test	cl, OPCODE_ENTRY_FLAG_INLINED
	cmovz	rdi, [rdi]
	
	ret
	
opcode_interpret:
	test	cl, OPCODE_ENTRY_FLAG_BYTECODE
	jnz	.bytecode

	call	rdi

	ret

.bytecode:
	mov	rax, rdi
	call	data_stack_push
	call	_call

	ret

opcode_compile:
	shr	ecx, 8
	and	ecx, 0xFF

	mov	rdi, [code_buffer_here]
	mov	rsi, [instruction_pointer]
	dec	rsi

	rep	movsb

	mov	[code_buffer_here], rdi
	mov	[instruction_pointer], rsi

	ret

; expects opcode in rax, address in rdi and flags in rcx
; TODO: clean up this indirection
opcode_handler_interpret:
	jmp	opcode_interpret
	
; expects opcode in rax, address in rdi and flags in rcx
opcode_handler_compile:
	test	cl, OPCODE_ENTRY_FLAG_IMMEDIATE
	jnz	opcode_interpret

	jmp	opcode_compile

; expects opcode in rax
_opcode_handler_invalid:
	mov	edi, eax
	jmp	exit

; expects opcode in rax
opcode_handler_call:
	push	rax
	call	opcode_map_entry

	test	rdi, rdi
	jz	.invalid

	; TODO: if the host set the opcode handler data_stack_push rdi, rcx, rax and call it
	pop	rax
	call	[opcode_handler]

	jmp	.done

.invalid:
	; TODO: if the host set the opcode invalid handler data_stack_push rax and call it
	pop	rax
	call	[opcode_handler_invalid]
	
.done:
	ret
