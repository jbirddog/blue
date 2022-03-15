
global read

global write

global exit

global exit.syserr

; : syscall1 ( arg1:edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : syscall3 ( arg3:edx arg2:esi arg1:edi num:eax -- result:eax )
__blue_1472650507_0:
	syscall
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

; : exit ( status:edi -- noret )
exit:
	mov eax, 60
	call __blue_1506205745_0

; : exit.syserr ( err:eax -- )
exit.syserr:
	neg eax
	mov edi, eax
	call exit
	ret
