
; expects start of stack fields offset in rdi, value to push in rax
stack_push:
	add	rdi, [mem]
	add	rdi, VM_DATA_OFFSET

	mov	rdx, rdi
	mov	ecx, CELL_SIZE
	
	add	rdi, CELL_SIZE
	push	rdi
	mov	rdi, [rdi]

	stosq

	mov	rsi, rdi
	pop	rdi
	mov	[rdi], rsi

	ret

; expects start of stack fields offset in rsi
stack_pop:
	add	rsi, [mem]
	add	rsi, VM_DATA_OFFSET

	mov	rdx, rsi
	mov	rcx, -CELL_SIZE
	
	add	rsi, CELL_SIZE
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
	mov	esi, VM_DATA_OFFSET_DATA_STACK_LOCATION
	call	stack_pop

	ret

; expects value to push in rax
data_stack_push:
	mov	edi, VM_DATA_OFFSET_DATA_STACK_LOCATION
	call	stack_push

	ret


; expects value to push in rax
return_stack_push:
	; TODO: bounds check
	mov	rdi, [return_stack_here]
	mov	[rdi], rax
	add	[return_stack_here], CELL_SIZE

	ret

return_stack_pop:
	; TODO: bounds check
	mov	rsi, [return_stack_here]
	mov	rax, [rsi - CELL_SIZE]
	sub	[return_stack_here], CELL_SIZE
	
	ret
