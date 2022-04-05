
global _start

; : syscall ( num:eax -- result:eax | rcx )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_1:
	mov eax, 60
	call __blue_4057121178_0

; : exit.ok ( -- noret )
__blue_3274522691_0:
	mov edi, 0
	call __blue_3454868101_1

; : _start ( -- noret )
_start:
	call __blue_3274522691_0
