
op_halt:
	xor	edi, edi
	jmp	exit
assert ($ - op_halt) <= CELL_SIZE

op_depth:
	call	data_stack_depth
	mov	eax, ecx
	call	data_stack_push
	
	ret

op_litb:
	call	read_byte
	call	data_stack_push
	
	ret

op_eq:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	pop	rcx

	xor	edi, edi
	xor	esi, esi
	not	rsi
	cmp	rcx, rax
	cmove	rax, rsi
	cmovne	rax, rdi

	call	data_stack_push
	
	ret

; TODO: replace with bytecode in extended opcode
op_assert:
	call	data_stack_pop
	mov	edi, eax
	not	edi
	test	edi, edi
	jnz	exit
	
	ret

op_drop:
	call	data_stack_pop
	
	ret
assert ($ - op_drop) <= CELL_SIZE
times (CELL_SIZE - ($ - op_drop)) db 0
assert ($ - op_drop) = CELL_SIZE

op_not:
	call	data_stack_pop
	not	rax
	call	data_stack_push
	
	ret

op_swap:
	call	data_stack_pop
	mov	rcx, rax
	call	data_stack_pop
	push	rax
	
	mov	rax, rcx
	call	data_stack_push
	pop	rax
	call	data_stack_push
	
	ret

op_compile:
	mov	[opcode_handler], OPCODE_HANDLER_COMPILE

	ret

op_interpret:
	mov	[opcode_handler], OPCODE_HANDLER_INTERPRET

	ret

op_start:
	mov	rax, [code_buffer]
	call	data_stack_push
	
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

op_byte_at:
	call	data_stack_pop
	mov	rsi, rax
	xor	eax, eax
	lodsb
	call	data_stack_push

	ret

op_here:
	mov	rax, [code_buffer_here]
	call	data_stack_push

	ret

op_execute:
	mov	rax, [instruction_pointer]
	call	return_stack_push

	call	data_stack_pop
	mov	[instruction_pointer], rax

	ret

op_ret:
	call	return_stack_pop
	mov	[instruction_pointer], rax
	
	ret

op_call:
	call	data_stack_pop
	call	rax

	ret
assert ($ - op_call) <= CELL_SIZE

op_b_set_inc:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	mov	rdi, rax
	pop	rax

	stosb
	
	mov	rax, rdi
	call	data_stack_push

	ret

; TODO: replace with bytecode
op_b_comma:
	call	data_stack_pop
	mov	rdi, [code_buffer_here]	
	stosb
	mov	[code_buffer_here], rdi
	
	ret

op_here_set:
	call	data_stack_pop
	mov	[code_buffer_here], rax

	ret
	
macro opN lbl, size, flags {
	db flags, size
	dw 0
	dd 0
	dq lbl
}

macro opNI lbl, size, flags {
}

_opcode_map:
	opN	op_halt, 1, 0
	opN	op_depth, 1, 0
	opN	op_litb, 2, 0
	opN	op_eq, 1, 0
	opN	op_assert, 1, 0
	opN	op_drop, 1, 0
	opN	op_not, 1, 0
	opN	op_swap, 1, 0
	opN	op_interpret, 1, OPCODE_ENTRY_FLAG_IMMEDIATE
	opN	op_compile, 1, 0
	opN	op_start, 1, 0
	opN	op_sub, 1, 0
	opN	op_add, 1, 0
	opN	op_byte_at, 1, 0
	opN	op_here, 1, 0
	opN	op_execute, 1, 0
	opN	op_ret, 1, 0
	opN	op_call, 1, 0
	opN	op_b_set_inc, 1, 0
	opN	op_b_comma, 1, 0
	opN	op_here_set, 1, 0
assert ($ - _opcode_map) <= (0x7F shl 4)
assert ($ - _opcode_map) <= 512
_opcode_map_qwords = ($ - _opcode_map) shr 3

opcode_map_init:
	mov	rdi, [opcode_map]
	mov	rsi, _opcode_map
	mov	ecx, _opcode_map_qwords

	rep	movsq
	
	ret

; expects opcode in rax
opcode_map_entry:
	mov	rsi, [opcode_map]
	shl	eax, 4
	add	rsi, rax

	mov	rcx, [rsi]
	lea	rdi, [rsi + 8]
	
	test	cl, OPCODE_ENTRY_FLAG_INLINED
	cmovz	rdi, [rdi]

	ret
	
opcode_interpret:
	; TODO: if the opcode is defined by the host, run it
	call	rdi

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

	; TODO: if the host has specified the opcode handler push rdi, rcx, rax and call it
	pop	rax
	call	[opcode_handler]

	jmp	.done

.invalid:
	pop	rax
	call	[opcode_handler_invalid]
	
.done:
	ret
