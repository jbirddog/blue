format elf64 executable 3

segment readable writable

mem dq 0

segment readable executable

include "defs.inc"
include "data_stack.inc"
include "input_buffer.inc"
include "opcodes.inc"


; expects status in edi
exit:
	mov	eax, 60
	syscall

syscall_or_die:
	syscall
	
	test	rax, rax
	cmovs	edi, eax
	js	exit

	ret

mmap_mem:
	MAP_ANONYMOUS = 32
	MAP_PRIVATE = 2

	PROT_READ = 1
	PROT_WRITE = 2
	PROT_EXEC = 4

	xor	edi, edi
	mov	esi, MEM_SIZE
	mov	edx, PROT_READ or PROT_WRITE or PROT_EXEC
	mov	r8d, -1
	xor	r9d, r9d
	mov	r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov	eax, 9
	call	syscall_or_die

	mov	[mem], rax
	ret

init_vm_data:
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
	mov	rax, interpret_opcode_handler
	stosq
	mov	rax, invalid_opcode_handler
	stosq

	ret

read_boot_code:
	xor	edi, edi
	mov	rsi, [mem]
	add	rsi, INPUT_BUFFER_OFFSET
	mov	edx, INPUT_BUFFER_SIZE
	xor	eax, eax
	call	syscall_or_die

	; store input buffer size
	mov	rdi, [mem]
	add	rdi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_INPUT_BUFFER_SIZE
	stosq

	ret

interpret_opcode_handler:
	mov	rsi, [mem]
	add	rsi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_DATA_STACK_HERE_LOCATION
	push	rsi

	mov	rsi, [rsi]
	std
	lodsq

	; TODO: check flags
	lodsq

	push	rsi
	
	lodsq
	cld

	pop	rsi
	pop	rdi
	mov	[rdi], rsi

	call	rax

	ret

compile_opcode_handler:
	mov edi, 67
	jmp exit
	
	ret

invalid_opcode_handler:
	mov edi, 53
	jmp exit
	
	ret

handle_opcode:
	mov	rsi, [mem]
	add	rsi, OPCODE_MAP_OFFSET
	shl	eax, 4
	add	rsi, rax

	mov	rdi, [rsi]
	test	rdi, rdi
	jz	.invalid_opcode

	call	data_stack_push_opcode_entry
	
	mov	rdi, [mem]
	add	rdi, CODE_BUFFER_OFFSET + VM_DATA_OFFSET_OPCODE_HANDLER_LOCATION
	mov	rdi, [rdi]
	call	rdi

	ret

.invalid_opcode:
	shr	eax, 4
	; TODO: push opcode on data stack and call invalid opcode handler
	call	invalid_opcode_handler
	
	ret
	
handle_input:
	call	input_buffer_read_byte
	test	ecx, ecx
	jz	.done
	
	call	handle_opcode
	
	jmp	handle_input
.done:
	ret

entry $
	call	mmap_mem
	call	init_vm_data
	call	init_opcode_map
	call	read_boot_code
	call	handle_input

	call	data_stack_depth
	mov	edi, ecx
	jmp	exit
