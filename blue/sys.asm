
global read

global read.stdin

global write

global write.stdin

global exit

; : syscall1 ( edi eax -- result:eax )
__blue_1506205745_0:
	syscall
	ret

; : syscall3 ( esi edx edi eax -- result:eax )
__blue_1472650507_0:
	syscall
	ret

; : read ( buf:esi len:edx fd:edi -- result:eax )
read:
	mov eax, 0
	call __blue_1472650507_0
	ret

; : read.stdin ( buf:esi len:edx -- result:eax )
read.stdin:
	mov edi, 0
	call read
	ret

; : write ( buf:esi len:edx fd:edi -- result:eax )
write:
	mov eax, 1
	call __blue_1472650507_0
	ret

; : write.stdout ( buf:esi len:edx -- result:eax )
__blue_2973566241_0:
	mov edi, 1
	call write
	ret

; : write.stderr ( buf:esi len:edx -- result:eax )
__blue_3820697666_0:
	mov edi, 3
	call write
	ret

; : exit ( status:edi -- noret )
exit:
	mov eax, 60
	call __blue_1506205745_0

; : exit.syserr ( err:eax -- )
__blue_1490145965_0:
	neg eax
	mov edi, eax
	call exit
	ret
