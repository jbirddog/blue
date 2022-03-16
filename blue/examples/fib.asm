extern exit

global _start

; : fib ( nth:ecx -- result:edi )
__blue_3169096246_0:
	mov edi, 0
	mov eax, 1

; : compute ( times:ecx accum:eax scratch:edi -- result:edi )
__blue_1147400058_0:
	xadd eax, edi
	loop __blue_1147400058_0
	ret

; : _start ( -- noret )
_start:
	mov ecx, 11
	call __blue_3169096246_0
	call exit
