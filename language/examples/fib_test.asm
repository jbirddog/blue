
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
	jmp __blue_3169096246_0

global exit

global bye

global die

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : die ( err:eax -- noret )

die:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )

exit:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

bye:
	xor edi, edi
	jmp exit

global _start

;  TODO exit with the test # that failed

; : test.failure ( -- )

__blue_1516647173_0:
	xor edi, edi
	inc edi
	jmp exit

; : test= ( actual:edi expected:eax -- )

__blue_2636330760_0:
	cmp eax, edi
	je __blue_2157056155_0
	call __blue_1516647173_0

__blue_2157056155_0:
	ret

; : _start ( -- noret )

_start:
	xor ecx, ecx
	inc ecx
	call __blue_3169096246_0
	xor eax, eax
	inc eax
	call __blue_2636330760_0
	mov ecx, 11
	call __blue_3169096246_0
	mov eax, 89
	call __blue_2636330760_0
	mov ecx, 14
	call __blue_3169096246_0
	mov eax, 377
	call __blue_2636330760_0
	mov ecx, 31
	call __blue_3169096246_0
	mov eax, 1346269
	call __blue_2636330760_0
	jmp bye
