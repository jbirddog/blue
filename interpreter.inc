
read_byte:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET + VM_DATA_OFFSET_INSTRUCTION_POINTER
	push	rsi
	mov	rsi, [rsi]
	
	xor	eax, eax
	lodsb

	pop	rdi
	mov	[rdi], rsi

	ret

outer_interpreter:
	call	read_byte
	call	opcode_handler_call
	
	jmp	outer_interpreter
