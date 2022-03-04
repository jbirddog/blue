global syscall1
global syscall3
global read
global write
global exit

syscall1:
	syscall
	ret

syscall3:
	syscall
	ret

read:
	mov eax, 0
	call syscall3
	ret

write:
	mov eax, 1
	call syscall3
	ret

exit:
	mov eax, 60
	call syscall1
