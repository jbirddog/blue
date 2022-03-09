
syscall1:
	syscall
	ret

syscall3:
	syscall
	ret

read:
	mov eax, 0
	call syscall3
	ret

global read

write:
	mov eax, 1
	call syscall3
	ret

global write

exit:
	mov eax, 60
	call syscall1

global exit

section .bss

section .text

buf.cap:
	ret

read.stdin:
	mov edi, 0
	call read
	ret

_start:
	mov edi, 0
	call exit

global _start
