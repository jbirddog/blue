
macro begin_op lbl, size, flags
latest_op = lbl
latest_op_code = ($ - opcode_tbl) shr 4
lbl##_code = latest_op_code
	db flags, size
end macro

macro opN lbl, size, flags
__opN_##lbl:
	begin_op lbl, size, flags

	dq lbl
	dw 0
	dd 0
	
	assert ($ - __opN_##lbl) = (CELL_SIZE * 2)
end macro

macro opNI lbl, size, flags
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_INLINED
.impl:
end macro

macro opBI lbl, size, flags
lbl:
	begin_op lbl, size, flags or OPCODE_ENTRY_FLAG_BYTECODE or OPCODE_ENTRY_FLAG_INLINED
end macro

macro end_op
	assert ($ - latest_op) <= (CELL_SIZE * 2)
	times ((CELL_SIZE * 2) - ($ - latest_op)) db 0
	assert ($ - latest_op) = (CELL_SIZE * 2)
end macro
