
global _start

; : syscall1 ( edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_1506205745_0

; : syscall3 ( edi esi edx eax -- result:eax )
__blue_1472650507_0:
	syscall
	ret

; : read ( fd:edi buf:esi len:edx -- result:eax )
__blue_3470762949_0:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : write ( fd:edi buf:esi len:edx -- result:eax )
__blue_3190202204_0:
	mov eax, 1
	call __blue_1472650507_0
	ret

section .bss

; ; 1024 resb buf
__blue_1926597602_0: resb 1024
section .text

; : read ( fd:edi -- result:eax )
__blue_3470762949_1:
	mov edx, 1024
	mov esi, __blue_1926597602_0
	call __blue_3470762949_0
	ret

; : write ( fd:edi -- result:eax )
__blue_3190202204_1:
	mov edx, 1024
	mov esi, __blue_1926597602_0
	call __blue_3190202204_0
	ret

;  : die? ( result:eax -- value:eax ) dup 0 cmp ' exit.syserr xl ;
;  TODO compare read/write bytes for exit status
; : _start ( -- noret )
_start:
	mov edi, 0
	call __blue_3470762949_1
	mov edi, 1
	call __blue_3190202204_1
	mov edi, 0
	call __blue_3454868101_0
