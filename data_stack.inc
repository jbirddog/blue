
data_stack_depth:
	mov	rsi, [mem]
	add	rsi, CODE_BUFFER_OFFSET

	mov	rcx, [rsi + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION]
	sub	rcx, [rsi + VM_DATA_OFFSET_DATA_STACK_LOCATION]
	shr	ecx, 3
	
	ret

data_stack_pop:
	mov	rsi, [mem]
	add	rsi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rsi
	mov	rsi, [rsi]

	std
	lodsq
	push	rsi
	lodsq
	cld

	pop	rsi
	pop	rdi
	mov	[rdi], rsi

	ret

data_stack_pop2:
	mov	rsi, [mem]
	add	rsi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rsi
	mov	rsi, [rsi]

	std
	lodsq
	lodsq
	mov	rcx, rax
	push	rsi
	lodsq
	cld

	pop	rsi
	pop	rdi
	mov	[rdi], rsi

	ret

; expects value to push in rax
data_stack_push:
	mov	rdi, [mem]
	add	rdi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rdi
	mov	rdi, [rdi]

	stosq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret

; expects opcode entry in rsi
data_stack_push_opcode_entry:
	; TODO: make sure two slots are available on the data stack
	
	mov	rdi, [mem]
	add	rdi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rdi
	mov	rdi, [rdi]

	movsq
	movsq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret
