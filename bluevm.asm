
format elf64 executable 3

DATA_STACK_SIZE = 1024
INPUT_BUFFER_SIZE = 2048
OPCODE_MAP_SIZE = 4096
RETURN_STACK_SIZE = 1024

segment readable writable executable

include "defs.inc"
include "stack.inc"
include "opcodes.inc"
include "interpreter.inc"
include "sys.inc"

mem_alloc_init:
	mov	esi, MEM_SIZE
	call	mmap_rwx

	mov	[mem], rax

	;lea	rsi, [rax + VM_ADDRS_OFFSET]
	;mov	rcx, opcode_handler_call
	;mov	[rsi], rcx
	
	;lea	rsi, [rax + CODE_BUFFER_OFFSET]
	;mov	[code_buffer], rsi
	;mov	[code_buffer_here], rsi

	ret

init:
	mov	[instruction_pointer], input_buffer
	mov	[return_stack_here], return_stack
	mov	[return_stack_size], RETURN_STACK_SIZE
	mov	[data_stack_here], data_stack
	mov	[data_stack_size], DATA_STACK_SIZE

	mov	[vm_addr_opcode_handler_call], opcode_handler_call
	mov	[code_buffer_here], code_buffer + VM_ADDRS_SIZE
	mov	[code_buffer_size], CODE_BUFFER_SIZE
	
	mov	[opcode_handler], OPCODE_HANDLER_INTERPRET
	mov	[opcode_handler_invalid], OPCODE_HANDLER_INVALID
	
	ret
	
read_boot_code:
	mov	rsi, input_buffer
	mov	edx, INPUT_BUFFER_SIZE
	call	read

	test	eax, eax
	cmovz	edi, eax
	jz	exit
		
	ret

entry $
	call	mem_alloc_init

	call	init
	call	read_boot_code	
	call	outer_interpreter


instruction_pointer rq 1
input_buffer rb INPUT_BUFFER_SIZE
return_stack rb RETURN_STACK_SIZE
return_stack_here rq 1
return_stack_size rq 1
data_stack rb DATA_STACK_SIZE
data_stack_here rq 1
data_stack_size rq 1
opcode_map rb OPCODE_MAP_SIZE

vm_addrs:
vm_addr_opcode_handler_call rq 1
times (VM_ADDRS_SIZE - ($ - vm_addrs)) rb 1
code_buffer rb (CODE_BUFFER_SIZE - VM_ADDRS_SIZE)
code_buffer_here rq 1
code_buffer_size rq 1


mem rq 1

opcode_handler rq 1
opcode_handler_invalid rq 1
