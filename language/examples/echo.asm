
global exit

global bye

global die

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : die ( err:eax -- noret )

die:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )

exit:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

bye:
	xor edi, edi
	jmp exit

global _start

; : syscall3 ( edi edx esi num:eax -- result:eax )

__blue_1472650507_0:
	jmp __blue_4057121178_0

; : unwrap ( result:eax -- value:eax )

__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call die

__blue_2157056155_0:
	ret

; : read ( fd len buf -- result )

__blue_3470762949_0:
	xor eax, eax
	jmp __blue_1472650507_0

; : write ( fd len buf -- result )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	jmp __blue_1472650507_0

section .bss

; 1024 resb buf

__blue_1926597602_0: resb 1024
section .text

; : read ( fd -- read )

__blue_3470762949_1:
	mov esi, __blue_1926597602_0
	mov edx, 1024
	call __blue_3470762949_0
	jmp __blue_4055961022_0

; : write ( len fd -- wrote )

__blue_3190202204_1:
	mov esi, __blue_1926597602_0
	call __blue_3190202204_0
	jmp __blue_4055961022_0

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
	jmp bye
