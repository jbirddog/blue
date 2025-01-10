
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
