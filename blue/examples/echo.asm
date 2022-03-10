
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

section .bss

buf: resb 1024
section .text

stdin2buf:
	mov edx, 1024
	mov esi, buf
	call read.stdin
	ret

buf2stdout:
	call write.stdout
	ret

_start:
	call stdin2buf
	mov edx, eax
	call buf2stdout
	mov edi, eax
	call exit

global _start
