
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

; : _start ( -- noret )
_start:
	call __blue_3274522691_0
