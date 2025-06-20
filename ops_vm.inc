
opBI	op_halt, 1, 0	;	( -- )	Exit with status of 0
	db op_litb_code, 0x00, op_litb_code, 0x3C, op_scall1_code
end_op

opBI	op_argc, 1, 0	;	( -- q )	Push argc
	db op_litq_code
	argc dq 0x00
	db op_ret_code
end_op

opBI	op_argv, 1, 0	;	( -- a )	Push addr of argv
	db op_litq_code
	argv dq 0x00
	db op_ret_code
end_op

macro scallx x
	push	CELL_SIZE * x
	jmp	_syscall##x
end macro

opNI	op_scall0, 1, 0	;	( d -- q )	Make syscall _d_ with no arguments
	scallx	0
end_op

opNI	op_scall1, 1, 0	;	( q0 d -- q )	Make syscall _d_ with one argument
	scallx	1
end_op

opNI	op_scall2, 1, 0	;	( q1 q0 d -- q )	Make syscall _d_ with arguments q0...q1
	scallx	2
end_op

opNI	op_scall3, 1, 0	;	( q2 q1 q0 d -- q )	Make syscall _d_ with arguments q0...q2
	scallx	3
end_op

opNI	op_scall4, 1, 0	;	( q3 q2 q1 q0 d -- q )	Make syscall _d_ with arguments q0...q3
	scallx	4
end_op

opNI	op_scall5, 1, 0	;	( q4 q3 q2 q1 q0 d -- q )	Make syscall _d_ with arguments q0...q4
	scallx	5
end_op

opNI	op_scall6, 1, 0	;	( q5 q4 q3 q2 q1 q0 d -- q )	Make syscall _d_ with arguments q0...q5
	scallx	6
end_op

opBI	op_blk, 1, 0	;	( b -- a )	Push addr of block number b
	db op_litb_code, 0x0A, op_shl_code, op_litq_code
	dq BLK_0
	db op_add_code, op_ret_code
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

opNI	op_fromr, 1, 0	;	( -- a )	Move top of return stack to data stack
	call	return_stack_pop
	call	data_stack_push

	ret
end_op

opNI	op_ret, 1, 0	;	( -- )	Pops value from return stack and sets the instruction pointer
	call	return_stack_pop
	mov	IP_REG, rax
	
	ret
end_op

opN	op_comp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- )	Begin compiling bytecode
opN	op_endcomp, 1, OPCODE_ENTRY_FLAG_IMMEDIATE	;	( -- a )	Append ret and end compilation, push addr where compilation started

opN	op_opentry, 1, 0	;	( b -- a )	Push addr of the entry in the op table for the opcode

macro setvarx x
	db op_opentry_code, op_litb_code, 0x03, op_add_code
	db op_swap_code, op_setinc##x##_code, op_drop_code
	db op_ret_code
end macro

opBI	op_setvarb, 1, 0	;	( b b -- )	Set litb value of var op
	setvarx	b
end_op

opBI	op_setvarw, 1, 0	;	( w b -- )	Set litw value of var op
	setvarx	w
end_op

opBI	op_setvard, 1, 0	;	( d b -- )	Set litd value of var op
	setvarx	d
end_op

opBI	op_setvarq, 1, 0	;	( q b -- )	Set litq value of var op
	setvarx	q
end_op

opNI	op_ip, 1, 0	;	( -- a )	Push location of the instruction pointer
	mov	rax, IP_REG
	call	data_stack_push

	ret
end_op

opNI	op_setip, 1, 0	;	( a -- )	Set the location of the instruction pointer
	call	data_stack_pop
	mov	IP_REG, rax

	ret
end_op

opBI	op_here, 1, 0	;	( -- a )	Push addr of the code buffer's here
	db op_litq_code
	code_buffer_here dq code_buffer
	db op_ret_code
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

macro cx x
	db op_here_code, op_swap_code, op_setinc##x##_code
	db op_litb_code, op_here_code, op_setvarq_code
	db op_ret_code
end macro

opBI	op_cb, 1, 0	;	( b -- )	Write byte value to and increment here
	cx	b
end_op

opBI	op_cw, 1, 0	;	( w -- )	Write word value to and increment here
	cx	w
end_op

opBI	op_cd, 1, 0	;	( d -- )	Write dword value to and increment here
	cx	d
end_op

opBI	op_cq, 1, 0	;	( q -- )	Write qword value to and increment here
	cx	q
end_op

macro litx x
	mov	rsi, IP_REG
	xor	eax, eax
	lods##x

	jmp	_post_lit
end macro

opNI	op_litb, 2, 0	;	( -- b )	Push next byte from and increment instruction pointer
	litx	b
end_op

opNI	op_litw, 3, 0	;	( -- w )	Push next word from and increment instruction pointer
	litx	w
end_op

opNI	op_litd, 5, 0	;	( -- d )	Push next dword from and increment instruction pointer
	litx	d
end_op

opNI	op_litq, 9, 0	;	( -- q )	Push next qword from and increment instruction pointer
	litx	q
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

opNI	op_and, 1, 0	;	( a b -- n )	Push logical and of a and b
	call	data_stack_pop2a
	and	rax, rcx
	call	data_stack_push

	ret
end_op

opNI	op_or, 1, 0	;	( a b -- n )	Push logical inclusive or of a and b
	call	data_stack_pop2a
	or	rax, rcx
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

