
op_halt:
	xor	edi, edi
	jmp	exit

op_depth:
	call	data_stack_depth
	mov	eax, ecx
	call	data_stack_push
	
	ret

op_litb:
	call	input_buffer_read_byte
	call	data_stack_push
	ret

op_eq:
	call	data_stack_pop2

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

op_not:
	call	data_stack_pop
	not	rax
	call	data_stack_push
	ret

op_swap:
	call	data_stack_pop2
	xchg	rcx, rax
	call	data_stack_push2
	ret

op_mode_compile:
	ret

op_mode_interpret:
	ret


opcode_map:
	dq op_halt, 0
	dq op_depth, 0
	dq op_litb, 0
	dq op_eq, 0
	dq op_assert, 0
	dq op_drop, 0
	dq op_not, 0
	dq op_swap, 0
	dq op_mode_interpret, 0
	dq op_mode_compile, 0
opcode_map_qwords = ($ - opcode_map) shr 3


init_opcode_map:
	mov	rdi, [mem]
	add	rdi, OPCODE_MAP_OFFSET
	mov	rsi, opcode_map
	mov	ecx, opcode_map_qwords

	rep	movsq
	
	ret

