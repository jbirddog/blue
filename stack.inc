
macro stack_push which {
; expects value to push in rax
which##_push:
	; TODO: bounds check
	mov	rdi, [which##_here]
	mov	[rdi], rax
	add	[which##_here], CELL_SIZE

	ret
}

macro stack_pop which {
which##_pop:
	; TODO: bounds check
	mov	rsi, [which##_here]
	mov	rax, [rsi - CELL_SIZE]
	sub	[which##_here], CELL_SIZE

	ret
}

data_stack_depth:
	mov	rcx, [data_stack_here]
	sub	rcx, [data_stack]
	shr	ecx, 3
	
	ret

stack_push data_stack
stack_pop data_stack

data_stack_push2:
	; TODO: bounds check
	mov	rdi, [data_stack_here]
	mov	[rdi], rcx
	mov	[rdi + CELL_SIZE], rax
	add	[data_stack_here], (CELL_SIZE * 2)

	ret

data_stack_pop2:
	; TODO: bounds check
	mov	rsi, [data_stack_here]
	lea	rax, [rsi - CELL_SIZE]
	mov	rax, [rax]
	lea	rcx, [rsi - (CELL_SIZE * 2)]
	mov	rcx, [rcx]
	sub	[data_stack_here], (CELL_SIZE * 2)
	
	ret

stack_push return_stack
stack_pop return_stack
