format elf64 executable 3

CELL_SIZE = 8

INPUT_BUFFER_OFFSET = 0
INPUT_BUFFER_SIZE = 1024

DATA_STACK_OFFSET = INPUT_BUFFER_SIZE
DATA_STACK_SIZE = 1024

OPCODE_MAP_OFFSET = DATA_STACK_OFFSET + DATA_STACK_SIZE
OPCODE_MAP_SIZE = 2048

CODE_BUFFER_OFFSET = OPCODE_MAP_OFFSET + OPCODE_MAP_SIZE
CODE_BUFFER_SIZE = 4096

MEM_SIZE = CODE_BUFFER_OFFSET + CODE_BUFFER_SIZE
assert MEM_SIZE = 8192

segment readable writable

mem dq 0

segment readable executable

; expects status in edi
exit:
	mov	eax, 60
	syscall

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
	syscall

	cmp	rax, 0
	jle	.err

	mov	[mem], rax
	ret
.err:
	mov	edi, eax
	jmp	exit

init_vm_data:
	mov	rsi, [mem]
	mov	rdi, rsi
	add	rdi, CODE_BUFFER_OFFSET

	; BlueVM state
	xor	eax, eax
	stosq

	; Location of input buffer, here and size
	mov	rax, rsi
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

	; TODO: Location of opcode handler
	xor	eax, eax
	stosq

	ret

entry $
	call	mmap_mem
	call	init_vm_data
	
	xor	edi, edi
	jmp	exit
