format elf64 executable 3

segment readable writable

mem dq 0

segment readable executable

include "defs.inc"
include "data_stack.inc"
include "input_buffer.inc"
include "opcodes.inc"
include "sys.inc"

mem_alloc:
	mov	esi, MEM_SIZE
	call	mmap_wrx

	mov	[mem], rax
	ret

; expects vm data field offset in rsi
vm_data_field_get:
	add	esi, CODE_BUFFER_OFFSET
	add	rsi, [mem]

	lodsq
	
	ret

; expects vm data field offset in rdi and value in rax
vm_data_field_set:
	add	edi, CODE_BUFFER_OFFSET
	add	rdi, [mem]

	stosq
	
	ret

vm_data_init:
	mov	rsi, [mem]
	mov	rdi, rsi
	add	rdi, CODE_BUFFER_OFFSET

	; BlueVM state
	xor	eax, eax
	stosq

	; Location of input buffer, here and size
	mov	rax, rsi
	add	rax, INPUT_BUFFER_OFFSET
	stosq
	stosq
	xor	eax, eax
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

	mov	rdi, VM_DATA_OFFSET_INPUT_BUFFER_SIZE
	call	vm_data_field_set
	
	ret
	
process_input:
	call	input_buffer_read_byte
	test	ecx, ecx
	jz	.done
	
	call	opcode_handler_call
	
	jmp	process_input
	
.done:
	ret

entry $
	call	mem_alloc
	call	vm_data_init
	call	opcode_map_init
	call	read_boot_code
	call	process_input

	call	data_stack_depth
	mov	edi, ecx
	jmp	exit
