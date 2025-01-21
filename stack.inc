
; expects stack in rdx, value to push in rax
stack_push:
	mov	rdi, [rdx]
	stosq
	add	qword [rdx], CELL_SIZE
	
	ret

; expects stack in rdx
stack_pop:

	
macro stack_pop which {
which##_pop:
	mov	rsi, [which##_here]
	mov	rax, [rsi - CELL_SIZE]
	sub	[which##_here], CELL_SIZE

	ret
}

data_stack_depth:
	mov	rcx, [data_stack_here]
	sub	rcx, data_stack
	shr	ecx, 3
	
	ret

data_stack_push:
	mov	rdx, data_stack_here
	jmp	stack_push

stack_pop data_stack

data_stack_push2:
	mov	rdi, [data_stack_here]
	mov	[rdi], rcx
	mov	[rdi + CELL_SIZE], rax
	add	[data_stack_here], (CELL_SIZE * 2)

	ret

data_stack_pop2:
	mov	rsi, [data_stack_here]
	lea	rax, [rsi - CELL_SIZE]
	mov	rax, [rax]
	lea	rcx, [rsi - (CELL_SIZE * 2)]
	mov	rcx, [rcx]
	sub	[data_stack_here], (CELL_SIZE * 2)
	
	ret

return_stack_push:
	mov	rdx, return_stack_here
	jmp	stack_push

stack_pop return_stack
