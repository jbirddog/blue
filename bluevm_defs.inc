
CELL_SIZE = 8
BLOCK_SIZE = 1024
ELF_HEADERS_SIZE = 120

VM_CODE_SIZE = 1024 - ELF_HEADERS_SIZE
RETURN_STACK_SIZE = 256
DATA_STACK_SIZE = 256
STACK_PADDING_SIZE = 512
VM_OPCODE_TBL_SIZE = 2048
EXT_OPCODE_TBL_SIZE = 2048
OPCODE_TBL_SIZE = VM_OPCODE_TBL_SIZE + EXT_OPCODE_TBL_SIZE
INPUT_BUFFER_SIZE = 1024
CODE_BUFFER_SIZE = 4096

VM_MEM_SIZE = VM_CODE_SIZE + \
	OPCODE_TBL_SIZE + \
	INPUT_BUFFER_SIZE + \
	RETURN_STACK_SIZE + \
	DATA_STACK_SIZE + \
	STACK_PADDING_SIZE + \
	CODE_BUFFER_SIZE

OPCODE_ENTRY_FLAG_IMMEDIATE = 1 shl 0
OPCODE_ENTRY_FLAG_INLINED = 1 shl 1
OPCODE_ENTRY_FLAG_BYTECODE = 1 shl 2

macro begin_op lbl, size, flags
latest_op = lbl
latest_op_code = (($ - opcode_tbl) shr 4) + opcode_tbl.offset
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
	repeat ((CELL_SIZE * 2) - ($ - latest_op))
		db 0
	end repeat
	assert ($ - latest_op) = (CELL_SIZE * 2)
end macro

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro
