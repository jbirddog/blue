
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
	mov	edi, VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	mov	rax, OPCODE_HANDLER_COMPILE
	call	vm_data_field_set

	ret

op_mode_interpret:
	mov	edi, VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	mov	rax, OPCODE_HANDLER_INTERPRET
	call	vm_data_field_set

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


opcode_map_init:
	mov	rdi, [mem]
	add	rdi, OPCODE_MAP_OFFSET
	mov	rsi, opcode_map
	mov	ecx, opcode_map_qwords

	rep	movsq
	
	ret

; expects opcode in rax
opcode_map_entry:
	mov	rsi, [mem]
	add	rsi, OPCODE_MAP_OFFSET
	shl	eax, 4
	add	rsi, rax

	mov	rdi, [rsi]
	mov	rcx, [rsi + 8]

	ret

; expects opcode in rax, address in rdi and flags in rcx
opcode_handler_compile:
	; TODO: check flags
	mov edi, 68
	jmp exit
	
	ret

; expects opcode in rax, address in rdi and flags in rcx
opcode_handler_interpret:
	; TODO: check flags
	call	rdi

	ret

; expects opcode in rax
opcode_handler_invalid:
	mov	edi, eax
	jmp	exit

; expects opcode in rax
opcode_handler_call:
	push	rax
	call	opcode_map_entry

	test	rdi, rdi
	jz	.invalid

	mov	esi, VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	call	vm_data_field_get

	; TODO: if the host has specified the opcode handler push rdi, rcx, rax and call it
	mov	rsi, rax
	pop	rax
	call	rsi

	jmp	.done

.invalid:
	mov	esi, VM_DATA_OFFSET_OPCODE_INVALID_HANDLER_LOCATION
	call	vm_data_field_get

	; TODO: if the host has specified the opcode invalid handler push rax and call it
	mov	rsi, rax
	pop	rax
	call	rsi
	
.done:
	ret
