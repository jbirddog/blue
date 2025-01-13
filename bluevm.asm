format elf64 executable 3

segment readable writable

mem dq 0

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

	; BlueVM state
	xor	eax, eax
	stosq

	; Location of instruction pointer
	mov	rax, rsi
	add	rax, INPUT_BUFFER_OFFSET
	stosq

	; Location of the input buffer and size
	stosq
	xor	eax, eax
	stosq
	
	; Location of return stack, here and size
	mov	rax, rsi
	add	rax, RETURN_STACK_OFFSET
	stosq
	stosq
	mov	eax, RETURN_STACK_SIZE
	stosq

	; Location of data stack, here and size
	mov	rax, rsi
	add	rax, DATA_STACK_OFFSET
	stosq
	stosq
	mov	eax, DATA_STACK_SIZE
	stosq

	; Location of the opcode map
	mov	rax, rsi
	add	rax, OPCODE_MAP_OFFSET
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
	call	opcode_map_init
	call	read_boot_code
	call	outer_interpreter
	
	
