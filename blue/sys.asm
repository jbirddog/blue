
global exit

global exit.syserr

global stdin

global stdout

global stderr

; : syscall1 ( arg1:edi num:eax -- result:eax )
__blue_1506205745_0:
	syscall
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
