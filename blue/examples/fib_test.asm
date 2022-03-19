
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

; : fib ( nth:ecx -- result:edi )
__blue_3169096246_0:
	mov edi, 0
	mov eax, 1

; : compute ( times:ecx accum:eax scratch:edi -- result:edi )
__blue_1147400058_0:
	xadd eax, edi
	loop __blue_1147400058_0
	ret

global _start

;  TODO failure code is test number that failed
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

;  TODO test cases - declare input and expected output
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
	call __blue_3274522691_0
