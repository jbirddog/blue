
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
_opcode_handler_invalid:
	mov	edi, eax
	jmp	exit

; expects opcode in rax
opcode_map_entry:
	mov	edx, eax
	shl	eax, 4
	
	mov	rsi, opcode_map
	add	rsi, rax
	mov	rcx, [rsi]
	lea	rdi, [rsi + 2]
	
	test	cl, OPCODE_ENTRY_FLAG_INLINED
	cmovz	rdi, [rdi]
	
	ret

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

read_byte:
	mov	rsi, [instruction_pointer]
	xor	eax, eax
	lodsb
	mov	[instruction_pointer], rsi

	ret

interpreter:
	call	read_byte
	call	opcode_handler_call
	
	jmp	interpreter
