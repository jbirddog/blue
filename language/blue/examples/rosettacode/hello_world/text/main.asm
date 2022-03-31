
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_1:
	mov eax, 60
	call __blue_4057121178_0

; : exit.ok ( -- noret )
__blue_3274522691_0:
	mov edi, 0
	call __blue_3454868101_1

; : syscall ( arg2:esi arg3:edx arg1:edi num:eax -- result:eax )
__blue_4057121178_1:
	call __blue_4057121178_0
	ret

; : write ( buf len -- )
__blue_3190202204_1:
	mov eax, 1
	mov edi, 1
	call __blue_4057121178_1
	ret

;  TODO string literals - s" Hello world!\n"
; : lf ( -- )
__blue_1261555351_0:

db 10
; : newline ( -- )
__blue_4281549323_0:
	mov edx, 1
	mov esi, __blue_1261555351_0
	call __blue_3190202204_1
	ret

; : hello-world ( -- )
__blue_1116541326_0:

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
; : hello-world ( -- )
__blue_1116541326_1:
	mov edx, 12
	mov esi, __blue_1116541326_0
	call __blue_3190202204_1
	call __blue_4281549323_0
	ret

; : _start ( -- noret )
_start:
	call __blue_1116541326_1
	call __blue_3274522691_0
