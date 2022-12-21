
global _start

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	jmp __blue_3454868101_0

; : write ( buf:esi len:edx fd:edi -- )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	call __blue_4057121178_0
	ret

; : print ( buf len -- )

__blue_372738696_0:
	xor edi, edi
	inc edi
	call __blue_3190202204_0
	ret

; : clear-screen ( -- )

__blue_1703174329_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 27,91,50,74,27,91,72,0
__blue_1223589535_0:
	mov edx, 7
	mov esi, __blue_855163316_0
	call __blue_372738696_0
	ret

; : _start ( -- noret )

_start:
	call __blue_1703174329_0
	jmp __blue_1911791459_0
