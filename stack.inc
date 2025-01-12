
; expects stack location offset in rdi, value to push in rax
stack_push:
	add	rdi, [mem]
	add	rdi, VM_DATA_OFFSET
	push	rdi
	mov	rdi, [rdi]

	stosq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret

; expects location offset in rsi
stack_pop:
	add	rsi, [mem]
	add	rsi, VM_DATA_OFFSET
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


data_stack_depth:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET

	mov	rcx, [rsi + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION]
	sub	rcx, [rsi + VM_DATA_OFFSET_DATA_STACK_LOCATION]
	shr	ecx, 3
	
	ret

data_stack_pop:
	mov	esi, VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	call	stack_pop

	ret

data_stack_pop2:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
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
	mov	edi, VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	call	stack_push

	ret

; expects value to push in rax then rcx
data_stack_push2:
	mov	rdi, [mem]
	add	rdi, VM_DATA_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rdi
	mov	rdi, [rdi]

	stosq
	mov	rax, rcx
	stosq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret

; expects start of entries in rsi, count in rcx
data_stack_pushN:
	mov	rdi, [mem]
	add	rdi, VM_DATA_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rdi
	mov	rdi, [rdi]

	rep movsq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret


; expects value to push in rax
return_stack_push:
	mov	edi, VM_DATA_OFFSET_RETURN_STACK_HERE_LOCATION
	call	stack_push

	ret

return_stack_pop:
	mov	esi, VM_DATA_OFFSET_RETURN_STACK_HERE_LOCATION
	call	stack_pop
	
	ret
