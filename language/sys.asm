
global read

global write

global exit

global exit.ok

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

; : exit.syserr ( err:eax -- noret )
exit.syserr:
	neg eax
	mov edi, eax

; : exit ( status:edi -- noret )
exit:
	mov eax, 60
	call __blue_1506205745_0

; : exit.ok ( -- noret )
exit.ok:
	mov edi, 0
	call exit
