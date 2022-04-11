
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

; : open ( pathname:edi flags:esi -- fd:eax )

__blue_3546203337_0:
	mov eax, 2
	call __blue_4057121178_0
	call __blue_4055961022_0
	ret

; : close ( fd:edi -- )

__blue_667630371_0:
	mov eax, 3
	call __blue_4057121178_0
	call __blue_1614081290_0
	ret

section .bss

; 48 resb stat_buf

__blue_1200943365_0: resb 48
; 8 resb file-size

__blue_1140937235_0: resb 8
; 88 resb padding

__blue_2157316278_0: resb 88
section .text

; : fstat ( fd:edi buf:esi -- )

__blue_1508683483_0:
	mov eax, 5
	call __blue_4057121178_0
	call __blue_1614081290_0
	ret

; : mmap ( fd:r8d len:esi addr:edi off:r9d prot:edx flags:r10d -- buf:eax )

__blue_776417966_0:
	mov eax, 9
	call __blue_4057121178_0
	call __blue_4055961022_0
	ret

; : munmap ( addr:edi len:esi -- )

__blue_287864331_0:
	mov eax, 11
	call __blue_4057121178_0
	call __blue_1614081290_0
	ret

section .bss

; 1 resd fd

__blue_1763898183_0: resd 1
section .text

; : open-file ( pathname:edi -- )

__blue_3225053210_0:
	mov esi, 0
	call __blue_3546203337_0
	mov [__blue_1763898183_0], eax
	ret

; : read-file-size ( -- )

__blue_1039529288_0:
	mov esi, __blue_1200943365_0
	mov edi, [__blue_1763898183_0]
	call __blue_1508683483_0
	ret

; : map-file ( fd len -- buf )

__blue_2864669986_0:
	mov r10d, 2
	mov edx, 1
	mov r9d, 0
	mov edi, 0
	call __blue_776417966_0
	ret

; : map-file ( -- buf )

__blue_2864669986_1:
	mov esi, [__blue_1140937235_0]
	mov r8d, [__blue_1763898183_0]
	call __blue_2864669986_0
	ret

; : unmap-file ( buf -- )

__blue_255719461_0:
	mov esi, [__blue_1140937235_0]
	call __blue_287864331_0
	ret

; : close-file ( -- )

__blue_2161677324_0:
	mov edi, [__blue_1763898183_0]
	call __blue_667630371_0
	ret

; : open-this-file ( -- )

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
	mov edi, __blue_855163316_0
	call __blue_3225053210_0
	ret

; : _start ( -- noret )

_start:
	call __blue_822887505_0
	call __blue_1039529288_0
	call __blue_2864669986_1

;  do something ...
	mov edi, eax
	call __blue_255719461_0
	call __blue_2161677324_0
	call __blue_1911791459_0
