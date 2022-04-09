
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
	mov edi, 0
	call __blue_3454868101_0

; : _start ( -- noret )
_start:
	call __blue_1911791459_0
