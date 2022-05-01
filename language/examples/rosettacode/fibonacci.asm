
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

; : example ( -- )

__blue_2347908769_0:
	mov ecx, 11
	call __blue_3169096246_0
	ret
