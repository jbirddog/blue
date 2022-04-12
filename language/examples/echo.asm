
global exit

global bye

global die

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : die ( err:eax -- noret )

__blue_3630339793_0:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	jmp __blue_3454868101_0

global _start

; : syscall3 ( edi edx esi num:eax -- result:eax )

__blue_1472650507_0:
	call __blue_4057121178_0
	ret

; : unwrap ( result:eax -- value:eax )

__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_3630339793_0

__blue_2157056155_0:
	ret

; : read ( fd len buf -- result )

__blue_3470762949_0:
	xor eax, eax
	call __blue_1472650507_0
	ret

; : write ( fd len buf -- result )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	call __blue_1472650507_0
	ret

section .bss

; 1024 resb buf

__blue_1926597602_0: resb 1024
section .text

; : read ( fd -- read )

__blue_3470762949_1:
	mov esi, __blue_1926597602_0
	mov edx, 1024
	call __blue_3470762949_0
	call __blue_4055961022_0
	ret

; : write ( len fd -- wrote )

__blue_3190202204_1:
	mov esi, __blue_1926597602_0
	call __blue_3190202204_0
	call __blue_4055961022_0
	ret

;  TODO compare read/write bytes for exit status

;  TODO loop until read 0

; : _start ( -- noret )

_start:
	xor edi, edi
	call __blue_3470762949_1
	xor edi, edi
	inc edi
	mov edx, eax
	call __blue_3190202204_1
	jmp __blue_1911791459_0
