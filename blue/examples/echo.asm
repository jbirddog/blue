
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

global read

read.stdin:
	mov edi, 0
	call read
	ret

global read.stdin

write:
	mov eax, 1
	call syscall3
	ret

global write

write.stdout:
	mov edi, 1
	call write
	ret

global write.stdout

write.stderr:
	mov edi, 3
	call write
	ret

global write.stderr

exit:
	mov eax, 60
	call syscall1

global exit

exit.syserr:
	neg eax
	mov edi, eax
	call exit
	ret

buf.cap:
	ret

section .bss

buf: resb 1024
section .text

orexit:
	cmp eax, 0
	jge ..@donecc
	call exit.syserr

..@donecc:
	ret

buf.read:
	mov edx, 1024
	mov esi, buf
	call read.stdin
	call orexit
	ret

buf.write:
	call write.stdout
	call orexit
	ret

_start:
	call buf.read
	mov edx, eax
	call buf.write
	mov edi, 0
	call exit

global _start
