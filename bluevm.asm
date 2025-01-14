format elf64 executable 3

segment readable writable

mem rq 1

instruction_pointer rq 1
input_buffer rq 1
return_stack rq 1
return_stack_here rq 1
return_stack_size rq 1
data_stack rq 1
data_stack_here rq 1
data_stack_size rq 1
opcode_map rq 1
code_buffer rq 1
code_buffer_here rq 1
code_buffer_size rq 1
opcode_handler rq 1
opcode_handler_invalid rq 1

segment readable executable

include "defs.inc"
include "stack.inc"
include "opcodes.inc"
include "interpreter.inc"
include "sys.inc"

mem_alloc:
	mov	esi, MEM_SIZE
	call	mmap_rwx

	mov	[mem], rax
	
	ret

vm_data_init:
	mov	rdi, [mem]
	
	lea	rsi, [rdi + INPUT_BUFFER_OFFSET]
	mov	[instruction_pointer], rsi
	mov	[input_buffer], rsi
	
	lea	rsi, [rdi + RETURN_STACK_OFFSET]
	mov	[return_stack], rsi
	mov	[return_stack_here], rsi
	mov	[return_stack_size], RETURN_STACK_SIZE
	
	lea	rsi, [rdi + DATA_STACK_OFFSET]
	mov	[data_stack], rsi
	mov	[data_stack_here], rsi
	mov	[data_stack_size], DATA_STACK_SIZE
	
	lea	rsi, [rdi + OPCODE_MAP_OFFSET]
	mov	[opcode_map], rsi

	lea	rsi, [rdi + VM_ADDRS_OFFSET]
	mov	rax, opcode_handler_call
	mov	[rsi], rax
	
	lea	rsi, [rdi + CODE_BUFFER_OFFSET]
	mov	[code_buffer], rsi
	mov	[code_buffer_here], rsi
	mov	[code_buffer_size], CODE_BUFFER_SIZE
	
	mov	[opcode_handler], OPCODE_HANDLER_INTERPRET
	mov	[opcode_handler_invalid], OPCODE_HANDLER_INVALID

	ret

read_boot_code:
	mov	rsi, [input_buffer]
	mov	edx, INPUT_BUFFER_SIZE
	call	read

	test	eax, eax
	cmovz	edi, eax
	jz	exit
		
	ret

entry $
	call	mem_alloc
	call	vm_data_init
	call	opcode_map_init
	call	read_boot_code
	call	outer_interpreter

