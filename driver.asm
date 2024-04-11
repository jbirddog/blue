	global _start

	section .text

_start:
	mov eax, 60
	mov edi, 0
	syscall
