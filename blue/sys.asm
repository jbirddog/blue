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
	call syscall3
	ret

write:
	call syscall3
	ret

exit:
	call syscall1
	ret
