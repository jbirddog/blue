
opcode_tbl:

opNI	op_exit, 1, 0	;	( b -- )	Exit with status from top of stack
	call	data_stack_pop
	mov	edi, eax
	jmp	exit
end_op

opNI	op_true, 1, 0	;	( -- t )	Push true value
	xor	eax, eax
	not	rax
	call	data_stack_push

	ret
end_op

opBI	op_false, 1, 0	;	( -- f )	Push false value
	db op_true_code, op_not_code, op_ret_code
end_op

opN	op_ifelse, 1, 0	;	( t/f ta fa -- ? )	Call ta if t/f is true else call fa

opNI	op_mccall, 1, 0	;	( a -- ? )	Call machine code at address
	call	data_stack_pop
	call	rax

	ret
end_op

opNI	op_call, 1, 0	;	( a -- ? )	Call bytecode located at address
	call	data_stack_pop
	call	_call

	ret
end_op

opNI	op_tor, 1, 0	;	( a -- )	Move top of data stack to return stack
	call	data_stack_pop
	call	return_stack_push

	ret
end_op

opNI	op_fromr, 1, 0	;	( -- a )	Move top of return stacl to data stack
	call	return_stack_pop
	call	data_stack_push

	ret
end_op

opNI	op_ret, 1, 0	;	( -- )	Pops value from return stack and sets the instruction pointer
	call	return_stack_pop
	mov	[instruction_pointer], rax
	
	ret
end_op

opN	op_comp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- )	Begin compiling bytecode
opN	op_endcomp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- a )	Append ret and end compilation, push addr where compilation started

opNI	op_ip, 1, 0	;	( -- a )	Push location of the instruction pointer
	mov	rax, [instruction_pointer]
	call	data_stack_push

	ret
end_op

opNI	op_setip, 1, 0	;	( a -- )	Set the location of the instruction pointer
	call	data_stack_pop
	mov	[instruction_pointer], rax

	ret
end_op

opN	op_op, 1, 0	;	( b -- a )	Push addr of the code for opcode

opNI	op_oph, 1, 0	;	( -- a )	Push addr of the opcode handler
	mov	rax, opcode_handler_call
	call	data_stack_push
	
	ret
end_op

opNI	op_start, 1, 0	;	( -- a )	Push addr of the code buffer's start
	mov	rax, code_buffer
	call	data_stack_push
	
	ret
end_op
	
opNI	op_here, 1, 0	;	( -- a )	Push addr of the code buffer's here
	mov	rax, [code_buffer_here]
	call	data_stack_push

	ret
end_op

opNI	op_sethere, 1, 0	;	( a -- )	Set addr of the code buffer's here
	call	data_stack_pop
	mov	[code_buffer_here], rax

	ret
end_op

opNI	op_atincb, 1, 0	;	( a -- b a' )	Push byte value found at addr, increment and push addr
	call	_atinc_pre
	lodsb

	jmp	_atinc_post
end_op

opNI	op_atincw, 1, 0	;	( a -- w a' )	Push word value found at addr, increment and push addr
	call	_atinc_pre
	lodsw

	jmp	_atinc_post
end_op

opNI	op_atincd, 1, 0	;	( a -- d a' )	Push dword value found at addr, increment and push addr
	call	_atinc_pre
	lodsd

	jmp	_atinc_post
end_op

opNI	op_atincq, 1, 0	;	( a -- q a' )	Push qword value found at addr, increment and push addr
	call	_atinc_pre
	lodsq

	jmp	_atinc_post
end_op

opBI	op_atb, 1, 0	;	( a -- b )	Push byte value found at addr
	db op_atincb_code, op_drop_code, op_ret_code
end_op

opBI	op_atw, 1, 0	;	( a -- d )	Push word value found at addr
	db op_atincw_code, op_drop_code, op_ret_code
end_op

opBI	op_atd, 1, 0	;	( a -- w )	Push dword value found at addr
	db op_atincd_code, op_drop_code, op_ret_code
end_op
	
opBI	op_atq, 1, 0	;	( a -- q )	Push qword value found at addr
	db op_atincq_code, op_drop_code, op_ret_code
end_op	

opNI	op_setincb, 1, 0	;	( a b -- 'a )	Write byte value to, increment and push addr
	call 	_set_pre
	stosb

	jmp	_set_post
end_op

opNI	op_setincw, 1, 0	;	( a w -- 'a )	Write word value to, increment and push addr
	call 	_set_pre
	stosw

	jmp	_set_post
end_op

opNI	op_setincd, 1, 0	;	( a d -- 'a )	Write dword value to, increment and push addr
	call 	_set_pre
	stosd

	jmp	_set_post
end_op
	

opNI	op_setincq, 1, 0	;	( a q -- 'a )	Write qword value to, increment and push addr
	call 	_set_pre
	stosq

	jmp	_set_post
end_op

opBI	op_setb, 1, 0	;	( a b -- )	Write byte value to addr
	db op_setincb_code, op_drop_code, op_ret_code
end_op

opBI	op_setw, 1, 0	;	( a w -- )	Write word value to addr
	db op_setincw_code, op_drop_code, op_ret_code
end_op

opBI	op_setd, 1, 0	;	( a d -- )	Write dword value to addr
	db op_setincd_code, op_drop_code, op_ret_code
end_op

opBI	op_setq, 1, 0	;	( a q -- )	Write qword value to addr
	db op_setincq_code, op_drop_code, op_ret_code
end_op

opBI	op_cb, 1, 0	;	( b -- )	Write byte value to and increment here
	db op_here_code, op_swap_code, op_setincb_code, op_sethere_code, op_ret_code
end_op

opBI	op_cw, 1, 0	;	( w -- )	Write word value to and increment here
	db op_here_code, op_swap_code, op_setincw_code, op_sethere_code, op_ret_code
end_op

opBI	op_cd, 1, 0	;	( d -- )	Write dword value to and increment here
	db op_here_code, op_swap_code, op_setincd_code, op_sethere_code, op_ret_code
end_op

opBI	op_cq, 1, 0	;	( q -- )	Write qword value to and increment here
	db op_here_code, op_swap_code, op_setincq_code, op_sethere_code, op_ret_code
end_op

opNI	op_litb, 2, 0	;	( -- b )	Push next byte from and increment instruction pointer
	call	_pre_lit
	lodsb

	jmp	_post_lit
end_op

opNI	op_litw, 3, 0	;	( -- w )	Push next word from and increment instruction pointer
	call	_pre_lit
	lodsw

	jmp	_post_lit
end_op

opNI	op_litd, 5, 0	;	( -- d )	Push next dword from and increment instruction pointer
	call	_pre_lit
	lodsd

	jmp	_post_lit
end_op

opNI	op_litq, 9, 0	;	( -- q )	Push next qword from and increment instruction pointer
	call	_pre_lit
	lodsq

	jmp	_post_lit
end_op

;
; stack ops
;

opNI	op_depth, 1, 0	;	( -- n )	Push depth of the data stack
	call	data_stack_depth
	mov	eax, ecx
	call	data_stack_push
	
	ret
end_op

opNI	op_dup, 1, 0	;	( x -- )	Drops top of the data stack
	call	data_stack_pop
	mov	rcx, rax
	call	data_stack_push2

	ret
end_op

opNI	op_drop, 1, 0	;	( a -- a a )	Duplicate top of stack
	call	data_stack_pop
	ret
end_op

opNI	op_swap, 1, 0	;	( a b -- b a )	Swap top two values on the data stack
	call	data_stack_pop2a
	call	data_stack_push2

	ret
end_op

opNI	op_not, 1, 0	;	( x -- 'x )	Bitwise not top of the data stack
	call	data_stack_pop
	not	rax
	call	data_stack_push
	
	ret
end_op

opN	op_eq, 1, 0	;	( a b -- t/f )	Check top two items for equality and push result

opNI	op_add, 1, 0	;	( a b -- n )	Push a + b
	call	data_stack_pop2
	add	rax, rcx
	call	data_stack_push

	ret
end_op

opNI	op_sub, 1, 0	;	( a b -- n )	Push a - b
	call	data_stack_pop2a
	sub	rax, rcx
	call	data_stack_push

	ret
end_op

opNI	op_shl, 1, 0	;	( x n -- 'x )	Push x shl n
	call	data_stack_pop2a
	shl	rax, cl
	call	data_stack_push

	ret
end_op

opNI	op_shr, 1, 0	;	( x n -- 'x )	Push x shr n
	call	data_stack_pop2a
	shr	rax, cl
	call	data_stack_push

	ret
end_op


assert (($ - opcode_tbl) and 0x07) = 0
assert ($ - opcode_tbl) <= VM_OPCODE_TBL_SIZE

