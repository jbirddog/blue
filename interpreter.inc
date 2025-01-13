
read_byte:
	mov	rsi, [instruction_pointer]
	xor	eax, eax
	lodsb
	mov	[instruction_pointer], rsi

	ret

outer_interpreter:
	call	read_byte
	call	opcode_handler_call
	
	jmp	outer_interpreter
