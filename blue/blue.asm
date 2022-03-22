
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : _start ( -- noret )
_start:
	mov eax, 60
	call __blue_4057121178_0
