
; expects opcode in rax, address in rdi and flags in rcx
opcode_handler_interpret:
	mov	rdx, _call
	mov	rax, rdi
	test	cl, OPCODE_ENTRY_FLAG_BYTECODE
	cmovnz	rdi, rdx

	call	rdi
	
	ret
	
; expects opcode in rax, address in rdi and flags in rcx
opcode_handler_compile:
	test	cl, OPCODE_ENTRY_FLAG_IMMEDIATE
	jnz	opcode_handler_interpret

	shr	ecx, 8
	and	ecx, 0xFF

	mov	rdi, [code_buffer_here]
	mov	rsi, [instruction_pointer]
	dec	rsi

	rep	movsb

	mov	[code_buffer_here], rdi
	mov	[instruction_pointer], rsi

	ret

; expects opcode in rax
opcode_tbl_entry:
	mov	edx, eax
	shl	eax, 4
	
	mov	rsi, opcode_tbl
	add	rsi, rax
	mov	rcx, [rsi]
	lea	rdi, [rsi + 2]
	
	test	cl, OPCODE_ENTRY_FLAG_INLINED
	cmovz	rdi, [rdi]
	
	ret

interpreter:
	mov	rsi, [instruction_pointer]
	xor	eax, eax
	lodsb
	mov	[instruction_pointer], rsi

	push	rax
	call	opcode_tbl_entry

	pop	rax
	call	[opcode_handler]
	
	jmp	interpreter
