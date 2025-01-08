format elf64 executable 3

CELL_SIZE = 8
INPUT_BUFFER_SIZE = 1024
DATA_STACK_SIZE = 1024
OPCODE_MAP_SIZE = 2048
CODE_BUFFER_SIZE = 4096

MEM_SIZE = INPUT_BUFFER_SIZE + DATA_STACK_SIZE + OPCODE_MAP_SIZE + CODE_BUFFER_SIZE
assert MEM_SIZE = 8192

segment readable writable

mem dq 0

segment readable executable

entry $
	xor	edi, edi
	mov	eax, 60
	syscall
