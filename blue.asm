format elf64 executable 3
	
segment readable executable

bob:
	mov edi, 33
	ret
	
entry $
	mov eax, 60
	call bob
	syscall
