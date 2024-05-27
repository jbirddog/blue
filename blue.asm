format elf64 executable

bob:
	mov edi, 3
	ret
	
entry $
	mov eax, 60
	call bob
	syscall
