
format ELF64 executable 3

CELL_SIZE = 8
VM_MAX_CODE_SIZE = 1024

RETURN_STACK_SIZE = 512
DATA_STACK_SIZE = 512
VM_OPCODE_TBL_SIZE = 2048
EXT_OPCODE_TBL_SIZE = 2048
OPCODE_TBL_SIZE = VM_OPCODE_TBL_SIZE + EXT_OPCODE_TBL_SIZE
INPUT_BUFFER_SIZE = 1024
CODE_BUFFER_SIZE = 4096

STACKS_SIZE = RETURN_STACK_SIZE + DATA_STACK_SIZE
BUFFERS_SIZE = INPUT_BUFFER_SIZE + CODE_BUFFER_SIZE
VM_MEM_SIZE = OPCODE_TBL_SIZE + BUFFERS_SIZE + STACKS_SIZE

OPCODE_HANDLER_COMPILE = opcode_handler_compile
OPCODE_HANDLER_INTERPRET = opcode_handler_interpret
OPCODE_HANDLER_INVALID = _opcode_handler_invalid

OPCODE_ENTRY_FLAG_IMMEDIATE = 1 shl 0
OPCODE_ENTRY_FLAG_INLINED = 1 shl 1
OPCODE_ENTRY_FLAG_BYTECODE = 1 shl 2

segment readable writeable executable

include "stack.inc"
include "ops_code.inc"
include "ops_macros.inc"
include "interpreter.inc"

; expects status in edi
exit:
	mov	eax, 60

syscall_or_die:
	syscall
	
	test	rax, rax
	cmovs	edi, eax
	js	exit

	ret

init:
	mov	[instruction_pointer], input_buffer
	mov	[opcode_handler], OPCODE_HANDLER_INTERPRET
	mov	[opcode_handler_invalid], OPCODE_HANDLER_INVALID
	
	mov	[return_stack_here], return_stack
	mov	[data_stack_here], data_stack
	mov	[code_buffer_here], code_buffer
	
	ret
	
read_boot_code:
	mov	rsi, input_buffer
	mov	edx, INPUT_BUFFER_SIZE
	xor	edi, edi
	xor	eax, eax
	call	syscall_or_die

	test	eax, eax
	cmovz	edi, eax
	jz	exit
		
	ret

entry $
	call	init
	call	read_boot_code	
	call	interpreter

opcode_tbl:
include "ops_vm.inc"
rb (OPCODE_TBL_SIZE - ($ - opcode_tbl))

input_buffer rb INPUT_BUFFER_SIZE

return_stack rb RETURN_STACK_SIZE
data_stack rb DATA_STACK_SIZE

code_buffer rb CODE_BUFFER_SIZE

assert ($ - opcode_tbl) = VM_MEM_SIZE

instruction_pointer rq 1

opcode_handler rq 1
opcode_handler_invalid rq 1

return_stack_here rq 1
data_stack_here rq 1
code_buffer_here rq 1
