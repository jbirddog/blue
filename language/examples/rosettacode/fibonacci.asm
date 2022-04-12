
; : fib ( nth:ecx -- result:edi )

__blue_3169096246_0:
	xor edi, edi
	xor eax, eax
	inc eax

; : compute ( times:ecx accum:eax scratch:edi -- result:edi )

__blue_1147400058_0:
	xadd eax, edi
	loop __blue_1147400058_0
	ret
