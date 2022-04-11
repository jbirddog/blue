
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

; : write ( buf:esi len:edx fd:edi -- )

__blue_3190202204_0:
	mov eax, 1
	call __blue_4057121178_0
	ret

; : print ( buf len -- )

__blue_372738696_0:
	mov edi, 1
	call __blue_3190202204_0
	ret

; : greet ( -- )

__blue_4213039946_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 72
db 101
db 108
db 108
db 111
db 32
db 119
db 111
db 114
db 108
db 100
db 33
db 10
db 0
__blue_1223589535_0:
	mov edx, 13
	mov esi, __blue_855163316_0
	call __blue_372738696_0
	ret

; : _start ( -- noret )

_start:
	call __blue_4213039946_0
	call __blue_1911791459_0
