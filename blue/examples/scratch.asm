extern exit

section .rodata

section .data

section .bss

section .text

; 
;  Entry point into the program
;  Only explaining this to test comments
; 
_start:
	mov edi, 0
	call exit

global _start
