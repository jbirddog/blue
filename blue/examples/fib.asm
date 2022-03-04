global _start
extern exit

fib:
	mov edi, 0
	mov eax, 1

.compute:
	xadd eax, edi
	loop .compute
	ret

_start:
	mov ecx, 11
	call fib
	call exit
