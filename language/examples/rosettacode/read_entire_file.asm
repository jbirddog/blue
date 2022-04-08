
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )
__blue_1911791459_0:
	mov edi, 0
	call __blue_3454868101_0

; : die ( err:eax -- noret )
__blue_3630339793_0:
	neg eax
	mov edi, eax
	call __blue_3454868101_0

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_3630339793_0

__blue_2157056155_0:
	ret

; : ordie ( result -- )
__blue_1614081290_0:
	call __blue_4055961022_0
	ret

section .bss

; 48 resb stat_buf
__blue_1200943365_0: resb 48
; 8 resb st_size
__blue_1358860734_0: resb 8
; 88 resb padding
__blue_2157316278_0: resb 88
section .text

; : open ( pathname:edi flags:esi -- fd:eax )
__blue_3546203337_0:
	mov eax, 2
	call __blue_4057121178_0
	call __blue_4055961022_0
	ret

; : fstat ( fd:edi buf:esi -- result:eax )
__blue_1508683483_0:
	mov eax, 5
	call __blue_4057121178_0
	ret

; : close ( fd:edi -- )
__blue_667630371_0:
	mov eax, 3
	call __blue_4057121178_0
	call __blue_1614081290_0
	ret

; : open-this-file ( -- fd:eax )
__blue_822887505_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 114
db 101
db 97
db 100
db 95
db 101
db 110
db 116
db 105
db 114
db 101
db 95
db 102
db 105
db 108
db 101
db 46
db 98
db 108
db 117
db 101
db 0
__blue_1223589535_0:
	mov esi, 0
	mov edi, __blue_855163316_0
	call __blue_3546203337_0
	ret

; : _start ( -- noret )
_start:
	call __blue_822887505_0
	mov esi, __blue_1200943365_0
	mov edi, eax
	call __blue_1508683483_0
	call __blue_1911791459_0
