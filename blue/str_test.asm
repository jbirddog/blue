
global read

global write

global exit

global exit.ok

global exit.syserr

; : syscall1 ( arg1:edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : syscall3 ( arg3:edx arg2:esi arg1:edi num:eax -- result:eax )
__blue_1472650507_0:
	syscall
	ret

; : read ( len:edx buf:esi fd:edi -- result:eax )
__blue_3470762949_0:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : write ( len:edx buf:esi fd:edi -- result:eax )
__blue_3190202204_0:
	mov eax, 1
	call __blue_1472650507_0
	ret

; : exit.syserr ( err:eax -- noret )
__blue_1490145965_0:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_1506205745_0

; : exit.ok ( -- noret )
__blue_3274522691_0:
	mov edi, 0
	call __blue_3454868101_0

; : skipws ( len:ecx buf:esi -- len:ecx buf:esi )
__blue_2423487636_0:
	lodsb
	cmp al, 32
	jg __blue_2106723298_0
	loop __blue_2423487636_0

__blue_2106723298_0:
	dec esi
	ret

global _start

;  TODO fail with test number as exit code
; : fail ( -- noret )
__blue_508790637_0:
	mov edi, 1
	call __blue_3454868101_0

; : data ( -- )
__blue_3631407781_0:

db 32
db 108
db 117
db 120
; : no-ws ( -- )
__blue_2134074831_0:
	mov esi, __blue_3631407781_0
	mov ecx, 4
	call __blue_2423487636_0
	cmp esi, __blue_3631407781_0
	je __blue_2157056155_0
	call __blue_508790637_0

__blue_2157056155_0:
	cmp ecx, 4
	je __blue_2157056155_1
	call __blue_508790637_0

__blue_2157056155_1:
	ret

;  4 const no-ws.len
;  1718383992 const no-ws.expected
; : _start ( -- noret )
_start:
	call __blue_2134074831_0
	call __blue_3274522691_0
