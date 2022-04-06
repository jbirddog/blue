
global _start

; : syscall ( num:eax -- result:eax | rcx )
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

; : exit.syserr ( err:eax -- noret )
__blue_1490145965_0:
	neg eax
	mov edi, eax
	call __blue_3454868101_1

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_1490145965_0

__blue_2157056155_0:
	ret

; : ordie ( result -- )
__blue_1614081290_0:
	call __blue_4055961022_0
	ret

; : syscall ( arg1:edi arg2:esi arg3:edx num:eax -- result:eax )
__blue_4057121178_1:
	call __blue_4057121178_0
	ret

; : open ( pathname flags mode -- fd )
__blue_3546203337_1:
	mov eax, 2
	call __blue_4057121178_1
	call __blue_4055961022_0
	ret

;  TODO base 8 would be interesting here
; : create-file ( pathname -- fd )
__blue_3101971046_0:
	mov edx, 416
	mov esi, 577
	call __blue_3546203337_1
	ret

; : create-files ( -- )
__blue_611137295_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 111
db 117
db 116
db 112
db 117
db 116
db 46
db 116
db 120
db 116
db 0
__blue_1223589535_0:
	mov edi, __blue_855163316_0
	call __blue_3101971046_0
	ret

; : make-directories ( -- )
__blue_2048448097_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 47
db 100
db 111
db 99
db 115
db 0
__blue_1223589535_1:
	ret

; : _start ( -- noret )
_start:
	call __blue_611137295_0
	call __blue_2048448097_0
	call __blue_3274522691_0
