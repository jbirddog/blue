extern exit

global _start

section .rodata

section .data

section .bss

section .text

; 
;  Entry point into the program
;  Only explaining this to test comments
; 
; : _start ( -- noret )
_start:
	mov edi, 0
	call exit
