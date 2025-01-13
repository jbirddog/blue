
data_stack_depth:
	mov	rcx, [data_stack_here]
	sub	rcx, [data_stack]
	shr	ecx, 3
	
	ret

; expects value to push in rax
data_stack_push:
	; TODO: bounds check
	mov	rdi, [data_stack_here]
	mov	[rdi], rax
	add	[data_stack_here], CELL_SIZE

	ret

data_stack_pop:
	; TODO: bounds check
	mov	rsi, [data_stack_here]
	mov	rax, [rsi - CELL_SIZE]
	sub	[data_stack_here], CELL_SIZE

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
