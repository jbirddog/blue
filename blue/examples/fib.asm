global syscall1
global exit
global fib
global _start

syscall1:
	syscall
	ret

exit:
	mov eax, 60
	call syscall1

fib:
	mov edi, 0
	mov eax, 1

.compute:
	xadd
	ret

_start:
	mov ecx, 11
	call fib
	call exit
