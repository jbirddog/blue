data_stack_push:
	mov	rdx, data_stack_here

; expects stack in rdx, value to push in rax
stack_push:
	mov	rdi, [rdx]
	stosq
	add	qword [rdx], CELL_SIZE
	
	ret

data_stack_pop:
	mov	rdx, data_stack_here

; expects stack in rdx
stack_pop:
	sub	qword [rdx], CELL_SIZE
	mov	rdx, [rdx]
	mov	rax, [rdx]

	ret

data_stack_depth:
	mov	rcx, [data_stack_here]
	sub	rcx, data_stack
	shr	ecx, 3
	
	ret

data_stack_push2:
	mov	rdx, data_stack_here
	mov	rdi, [rdx]
	mov	[rdi], rcx
	mov	[rdi + CELL_SIZE], rax
	add	qword [rdx], (CELL_SIZE * 2)

	ret

data_stack_pop2:
	mov	rdx, data_stack_here
	mov	rsi, [rdx]
	mov	rax, [rsi - CELL_SIZE]
	mov	rcx, [rsi - (CELL_SIZE * 2)]
	sub	qword [rdx], (CELL_SIZE * 2)
	
	ret

data_stack_pop2a:
	call	data_stack_pop2
	xchg	rax, rcx
	ret

return_stack_push:
	mov	rdx, return_stack_here
	jmp	stack_push

return_stack_pop:
	mov	rdx, return_stack_here
	jmp	stack_pop
