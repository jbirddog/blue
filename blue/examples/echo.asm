
global _start

; : syscall1 ( edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : fail ( err:edi -- noret )
__blue_508790637_0:
	neg edi
	mov eax, 60
	call __blue_1506205745_0

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_508790637_0

__blue_2157056155_0:
	ret

; : syscall3 ( edi esi edx eax -- result:eax )
__blue_1472650507_0:
	syscall
	ret

; : read ( fd:edi buf:esi len:edx -- result:eax )
__blue_3470762949_0:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : syscall3 ( edx edi esi eax -- result:eax )
__blue_1472650507_1:
	syscall
	ret

; : write ( len:edx fd:edi buf:esi -- result:eax )
__blue_3190202204_0:
	mov eax, 1
	call __blue_1472650507_1
	ret

section .bss

; ; 1024 resb buf
__blue_1926597602_0: resb 1024
section .text

; : read ( fd:edi -- read:eax )
__blue_3470762949_1:
	mov edx, 1024
	mov esi, __blue_1926597602_0
	call __blue_3470762949_0
	call __blue_4055961022_0
	ret

; : write ( len:edx fd:edi -- wrote:eax )
__blue_3190202204_1:
	mov esi, __blue_1926597602_0
	call __blue_3190202204_0
	call __blue_4055961022_0
	ret

;  TODO hide buf
; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_1506205745_0

;  TODO compare read/write bytes for exit status
; : _start ( -- noret )
_start:
	mov edi, 0
	call __blue_3470762949_1
	mov edi, 1
	mov edx, eax
	call __blue_3190202204_1
	mov edi, 0
	call __blue_3454868101_0
