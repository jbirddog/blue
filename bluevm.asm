format elf64 executable 3

segment readable writable

mem rq 1

instruction_pointer rq 1

return_stack rq 1
return_stack_here rq 1
return_stack_size rq 1

opcode_map rq 1

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
	mov	rsi, [mem]
	mov	rdi, rsi
	add	rdi, VM_DATA_OFFSET

	; BlueVM state - migrated by removing until used
	xor	eax, eax
	stosq

	; Location of instruction pointer - migrated
	stosq

	; Location of the input buffer and size
	stosq
	xor	eax, eax
	stosq
	
	; Location of return stack, here and size - migrated
	xor	eax, eax
	stosq
	stosq
	stosq

	; Location of data stack, here and size
	mov	rax, rsi
	add	rax, DATA_STACK_OFFSET
	stosq
	stosq
	mov	eax, DATA_STACK_SIZE
	stosq

	; Location of the opcode map - migrated
	xor	eax, eax
	stosq

	; Location of code buffer, here and size
	mov	rax, rsi
	add	rax, CODE_BUFFER_OFFSET
	stosq
	stosq
	mov	eax, CODE_BUFFER_SIZE
	stosq

	; Location of opcode handlers
	mov	rax, OPCODE_HANDLER_INTERPRET
	stosq
	mov	rax, OPCODE_HANDLER_INVALID
	stosq

	ret

vm_data_init2:
	mov	rdi, [mem]

	lea	rsi, [rdi + INPUT_BUFFER_OFFSET]
	mov	[instruction_pointer], rsi
	
	lea	rsi, [rdi + RETURN_STACK_OFFSET]
	mov	[return_stack], rsi
	mov	[return_stack_here], rsi
	mov	[return_stack_size], RETURN_STACK_SIZE
	
	lea	rsi, [rdi + OPCODE_MAP_OFFSET]
	mov	[opcode_map], rsi

	ret

read_boot_code:
	mov	rsi, [mem]
	add	rsi, INPUT_BUFFER_OFFSET
	mov	edx, INPUT_BUFFER_SIZE
	call	read

	test	eax, eax
	cmovz	edi, eax
	jz	exit
	
	mov	edi, VM_DATA_OFFSET_INPUT_BUFFER_SIZE
	call	vm_data_field_set
	
	ret

entry $
	call	mem_alloc
	call	vm_data_init
	call	vm_data_init2
	call	opcode_map_init
	call	read_boot_code
	call	outer_interpreter
	
	
