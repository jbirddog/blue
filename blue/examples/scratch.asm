extern exit

global _start

section .rodata

section .data

section .bss

section .text

; : #!@$% ( status:edi -- noret )
__blue_3160614312_0:
	call exit

; 
;  Entry point into the program
;  Only explaining this to test comments
; 
;  set the exit code 
;  call exit wrapper, just testing comments in words here 
; : _start ( -- noret )
_start:
	mov edi, 0
	call __blue_3160614312_0
