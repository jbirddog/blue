
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

; : open ( pathname:edi flags:esi mode:edx -- fd:eax )
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

; : mkdir ( pathname:edi mode:esi -- )
__blue_2883839448_0:
	mov eax, 83
	call __blue_4057121178_0
	call __blue_1614081290_0
	ret

; : create-file ( pathname -- )
__blue_3101971046_0:
	mov edx, 416
	mov esi, 577
	call __blue_3546203337_0
	mov edi, eax
	call __blue_667630371_0
	ret

; : make-directory ( pathname -- )
__blue_2358895277_0:
	mov esi, 488
	call __blue_2883839448_0
	ret

; : create-output-file ( -- )
__blue_2468950182_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 111
db 117
db 116
db 112
db 117
db 116
db 46
db 116
db 120
db 116
db 0
__blue_1223589535_0:
	mov edi, __blue_855163316_0
	call __blue_3101971046_0
	ret

; : make-docs-directory ( -- )
__blue_2374470879_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 100
db 111
db 99
db 115
db 0
__blue_1223589535_1:
	mov edi, __blue_855163316_1
	call __blue_2358895277_0
	ret

; : _start ( -- noret )
_start:
	call __blue_2468950182_0
	call __blue_2374470879_0
	call __blue_1911791459_0
