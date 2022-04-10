
global read

global write

global exit

global bye

global die

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : syscall3 ( arg3:edx arg2:esi arg1:edi num:eax -- result:eax )
__blue_1472650507_0:
	call __blue_4057121178_0
	ret

; : read ( len:edx buf:esi fd:edi -- result:eax )
read:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : write ( len:edx buf:esi fd:edi -- result:eax )
write:
	mov eax, 1
	call __blue_1472650507_0
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
	mov edi, 0
	call exit
