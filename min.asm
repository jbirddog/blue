format elf64 executable 3

segment readable writable executable

entry $
	mov edi, 7
	mov eax, 60
	syscall
