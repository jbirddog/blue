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

exit_ok:
	xor	edi, edi

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
	add	rax, CODE_BUFFER_OFFSET
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

read_boot_code:
	xor	edi, edi
	mov	rsi, [mem]
	add	rsi, INPUT_BUFFER_OFFSET
	mov	edx, INPUT_BUFFER_SIZE
	xor	eax, eax
	call	syscall_or_die
	
	ret

handle_input:
	ret

entry $
	call	mmap_mem
	call	init_vm_data
	call	read_boot_code
	call	handle_input
	
	jmp	exit_ok
