
op_halt:
	xor	edi, edi
	jmp	exit

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

op_compile:
	mov	edi, VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	mov	rax, OPCODE_HANDLER_COMPILE
	call	vm_data_field_set

	ret

op_interpret:
	mov	edi, VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	mov	rax, OPCODE_HANDLER_INTERPRET
	call	vm_data_field_set

	ret

op_start:
	mov	esi, VM_DATA_OFFSET_CODE_BUFFER_LOCATION
	call	vm_data_field_get
	call	data_stack_push
	
	ret

op_sub:
	call	data_stack_pop2
	sub	rax, rcx
	call	data_stack_push

	ret

op_add:
	call	data_stack_pop2
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
	mov	esi, VM_DATA_OFFSET_CODE_BUFFER_HERE_LOCATION
	call	vm_data_field_get
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

op_b_comma:
	call	data_stack_pop
	push	rax

	mov	esi, VM_DATA_OFFSET_CODE_BUFFER_HERE_LOCATION
	call	vm_data_field_get

	mov	rdi, rax
	pop	rax
	
	stosb

	mov	rax, rdi
	mov	edi, VM_DATA_OFFSET_CODE_BUFFER_HERE_LOCATION
	call	vm_data_field_set
	
	ret
	
macro op lbl, size, flags {
	dq lbl
	db flags, size
	dw 0
	dd 0
}

_opcode_map:
	op	op_halt, 1, 0
	op	op_depth, 1, 0
	op	op_litb, 2, 0
	op	op_eq, 1, 0
	op	op_assert, 1, 0
	op	op_drop, 1, 0
	op	op_not, 1, 0
	op	op_swap, 1, 0
	op	op_interpret, 1, OPCODE_ENTRY_FLAG_IMMEDIATE
	op	op_compile, 1, 0
	op	op_start, 1, 0
	op	op_sub, 1, 0
	op	op_add, 1, 0
	op	op_byte_at, 1, 0
	op	op_here, 1, 0
	op	op_execute, 1, 0
	op	op_ret, 1, 0
	op	op_call, 1, 0
	op	op_b_comma, 1, 0
assert ($ - _opcode_map) <= (0x7F shl 4)
_opcode_map_qwords = ($ - _opcode_map) shr 3

opcode_map_init:
	mov	rdi, [opcode_map]
	mov	rsi, _opcode_map
	mov	ecx, _opcode_map_qwords

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
	
opcode_interpret:
	; TODO: if the opcode is defined by the host, run it
	call	rdi

	ret

opcode_compile:
	shr	ecx, 8
	and	ecx, 0xFF

	mov	r8d, VM_DATA_OFFSET_CODE_BUFFER_HERE_LOCATION

	mov	esi, r8d
	call	vm_data_field_get
	mov	rdi, rax

	mov	rsi, [instruction_pointer]
	dec	rsi

	rep	movsb

	mov	[instruction_pointer], rsi

	mov	rax, rdi
	mov	edi, r8d
	call	vm_data_field_set

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
