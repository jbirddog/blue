
input_buffer_bytes_available:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET

	mov	rcx, [rsi + VM_DATA_OFFSET_INPUT_BUFFER_LOCATION]
	sub	rcx, [rsi + VM_DATA_OFFSET_INSTRUCTION_POINTER]
	add	rcx, [rsi + VM_DATA_OFFSET_INPUT_BUFFER_SIZE]

	ret

read_byte:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET + VM_DATA_OFFSET_INSTRUCTION_POINTER
	push	rsi
	mov	rsi, [rsi]
	
	lodsb

	pop	rdi
	mov	[rdi], rsi

	ret

outer_interpreter:
	call	input_buffer_bytes_available
	cmp	ecx, 0
	jle	.done

	xor	eax, eax
	call	read_byte
	call	opcode_handler_call
	
	jmp	outer_interpreter
	
.done:
	call	data_stack_depth
	mov	edi, ecx
	jmp	exit
