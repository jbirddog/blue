format elf64 executable 3

segment readable writable

mem dq 0

segment readable executable

entry $
	xor	edi, edi
	mov	eax, 60
	syscall
