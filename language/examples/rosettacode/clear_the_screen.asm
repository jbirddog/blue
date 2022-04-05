
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

; : cls ( -- )
__blue_59780555_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 27
db 91
db 50
db 74
db 27
db 91
db 72
db 0
__blue_1223589535_0:
	mov edx, 7
	mov esi, __blue_855163316_0
	call __blue_3190202204_1
	ret

; : _start ( -- noret )
_start:
	call __blue_59780555_0
	call __blue_3274522691_0
