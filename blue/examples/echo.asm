
global read

global write

global exit

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

; : syscall3 ( edi edx esi num:eax -- result:eax )
__blue_1472650507_1:
	syscall
	ret

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_1490145965_0

__blue_2157056155_0:
	ret

; : read ( fd:edi len:edx buf:esi -- result:eax )
__blue_3470762949_1:
	mov eax, 0
	call __blue_1472650507_1
	ret

; : write ( fd:edi len:edx buf:esi -- result:eax )
__blue_3190202204_1:
	mov eax, 1
	call __blue_1472650507_1
	ret

;  TODO clamp for 0 <= len <= buf.cap for write's variable len
;  pmaxud, pminud?
section .bss

; 1024 resb buf
__blue_1926597602_0: resb 1024
section .text

; : read ( fd:edi -- read:eax )
__blue_3470762949_2:
	mov esi, __blue_1926597602_0
	mov edx, 1024
	call __blue_3470762949_1
	call __blue_4055961022_0
	ret

; : write ( len:edx fd:edi -- wrote:eax )
__blue_3190202204_2:
	mov esi, __blue_1926597602_0
	call __blue_3190202204_1
	call __blue_4055961022_0
	ret

;  TODO compare read/write bytes for exit status
; : _start ( -- noret )
_start:
	mov edi, 0
	call __blue_3470762949_2
	mov edi, 1
	mov edx, eax
	call __blue_3190202204_2
	mov edi, 0
	call __blue_3454868101_0
