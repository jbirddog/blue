extern exit

section .rodata

section .data

section .bss

section .text

_start:
	mov edi, 0
	call exit

global _start
