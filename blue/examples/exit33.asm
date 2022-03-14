
global exit

global exit.syserr

global stdin

global stdout

global stderr

; : syscall1 ( arg1:edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_1506205745_0

; : exit.syserr ( err:eax -- )
__blue_1490145965_0:
	neg eax
	mov edi, eax
	call __blue_3454868101_0
	ret

global _start

; : _start ( -- noret )
_start:
	mov edi, 33
	call __blue_3454868101_0
