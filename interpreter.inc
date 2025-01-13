
read_byte:
	mov	rsi, [ptr_to.ip]
	xor	eax, eax
	lodsb
	mov	[ptr_to.ip], rsi

	ret

outer_interpreter:
	call	read_byte
	call	opcode_handler_call
	
	jmp	outer_interpreter
