
macro stack_push name, reg
name##_stack_push:
	mov	[reg], rax
	add	reg, CELL_SIZE
	
	ret
end macro

macro stack_pop name, reg
name##_stack_pop:
	sub	reg, CELL_SIZE
	mov	rax, [reg]
	
	ret
end macro

stack_push	data, DS_REG
stack_pop	data, DS_REG

data_stack_depth:
	mov	rcx, DS_REG
	sub	rcx, data_stack
	shr	ecx, 3
	
	ret

data_stack_push2:
	mov	[DS_REG], rcx
	mov	[DS_REG + CELL_SIZE], rax
	add	DS_REG, (CELL_SIZE * 2)

	ret

data_stack_pop2:
	mov	rax, [DS_REG - CELL_SIZE]
	sub	DS_REG, (CELL_SIZE * 2)
	mov	rcx, [DS_REG]
	
	ret

data_stack_pop2a:
	call	data_stack_pop2
	xchg	rax, rcx
	
	ret

stack_push	return, RS_REG
stack_pop	return, RS_REG
