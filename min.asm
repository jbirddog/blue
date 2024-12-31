format elf64 executable 3

segment readable writable executable

xor eax, eax
xor edi, edi

entry $
	mov edi, 7
	mov eax, 60
	syscall
