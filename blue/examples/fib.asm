extern exit

global _start

; : fib ( nth:ecx -- result:edi )
fib:
	mov edi, 0
	mov eax, 1

; :> compute ( accum:eax scratch:edi -- result )
.compute:
	xadd eax, edi
	loop .compute
	ret

; : _start ( -- noret )
_start:
	mov ecx, 11
	call fib
	call exit
