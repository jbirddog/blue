global _start

syscall1:
	syscall
	ret

exit:
	mov eax, 60
	call syscall1

_start:
	mov edi, 33
	call exit
