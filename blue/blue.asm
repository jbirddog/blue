
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:rdi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : _start ( rsp -- noret )
_start:
	mov rdi, [rsp]
	call __blue_3454868101_0
