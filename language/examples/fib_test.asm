
; : fib ( nth:ecx -- result:edi )

__blue_3169096246_0:
	xor edi, edi
	mov eax, 1

; : compute ( times:ecx accum:eax scratch:edi -- result:edi )

__blue_1147400058_0:
	xadd eax, edi
	loop __blue_1147400058_0
	ret

global exit

global bye

global die

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : die ( err:eax -- noret )

__blue_3630339793_0:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	call __blue_3454868101_0

global _start

;  TODO exit with the test # that failed

; : test.failure ( -- )

__blue_1516647173_0:
	mov edi, 1
	call __blue_3454868101_0
	ret

; : test= ( actual:edi expected:eax -- )

__blue_2636330760_0:
	cmp eax, edi
	je __blue_2157056155_0
	call __blue_1516647173_0

__blue_2157056155_0:
	ret

; : _start ( -- noret )

_start:
	mov ecx, 1
	call __blue_3169096246_0
	mov eax, 1
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
	call __blue_1911791459_0
