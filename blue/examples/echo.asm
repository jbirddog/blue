
global read

global read.stdin

global write

global write.stdin

global exit

; : syscall1 ( edi eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : syscall3 ( esi edx edi eax -- result:eax )
__blue_1472650507_0:
	syscall
	ret

; : read ( buf:esi len:edx fd:edi -- result:eax )
__blue_3470762949_0:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : read.stdin ( buf:esi len:edx -- result:eax )
__blue_1792571673_0:
	mov edi, 0
	call __blue_3470762949_0
	ret

; : write ( buf:esi len:edx fd:edi -- result:eax )
__blue_3190202204_0:
	mov eax, 1
	call __blue_1472650507_0
	ret

; : write.stdout ( buf:esi len:edx -- result:eax )
__blue_2973566241_0:
	mov edi, 1
	call __blue_3190202204_0
	ret

; : write.stderr ( buf:esi len:edx -- result:eax )
__blue_3820697666_0:
	mov edi, 3
	call __blue_3190202204_0
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

section .bss

; ; 1024 resb buf
__blue_1926597602_0: resb 1024
section .text

; : orexit ( result:eax -- value:eax )
__blue_1846591124_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_1490145965_0

__blue_2157056155_0:
	ret

; : read ( -- buf:esi read:eax )
__blue_3470762949_1:
	mov edx, 1024
	mov esi, __blue_1926597602_0
	call __blue_1792571673_0
	call __blue_1846591124_0
	ret

; : write ( buf:esi len:edx -- wrote:eax )
__blue_3190202204_1:
	call __blue_2973566241_0
	call __blue_1846591124_0
	ret

;  TODO also still a bit loose with effect handling as seen with exit
; : _start ( -- noret )
_start:
	call __blue_3470762949_1
	mov edx, eax
	call __blue_3190202204_1
	mov edi, 0
	call __blue_3454868101_0
