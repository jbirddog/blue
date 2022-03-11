
; : syscall1 ( edi eax -- result:eax )
syscall1:
	syscall
	ret

; : syscall3 ( esi edx edi eax -- result:eax )
syscall3:
	syscall
	ret

; : read ( buf:esi len:edx fd:edi -- result:eax )
read:
	mov eax, 0
	call syscall3
	ret

global read

; : read.stdin ( buf:esi len:edx -- result:eax )
read.stdin:
	mov edi, 0
	call read
	ret

global read.stdin

; : write ( buf:esi len:edx fd:edi -- result:eax )
write:
	mov eax, 1
	call syscall3
	ret

global write

; : write.stdout ( buf:esi len:edx -- result:eax )
write.stdout:
	mov edi, 1
	call write
	ret

global write.stdout

; : write.stderr ( buf:esi len:edx -- result:eax )
write.stderr:
	mov edi, 3
	call write
	ret

global write.stderr

; : exit ( status:edi -- noret )
exit:
	mov eax, 60
	call syscall1

global exit

; : exit.syserr ( err:eax -- )
exit.syserr:
	neg eax
	mov edi, eax
	call exit
	ret

; : buf.cap ( -- )
buf.cap:
	ret

section .bss

;  TODO resolve run issue with using buf.cap below
buf: resb 1024
section .text

; : orexit ( result:eax -- value:eax )
orexit:
	cmp eax, 0
	jge ..@donecc
	call exit.syserr

..@donecc:
	ret

; : buf.read ( -- buf:esi read:eax )
buf.read:
	mov edx, 1024
	mov esi, buf
	call read.stdin
	call orexit
	ret

; : buf.write ( buf:esi len:edx -- wrote:eax )
buf.write:
	call write.stdout
	call orexit
	ret

;  TODO also still a bit loose with effect handling as seen with exit
; : _start ( -- noret )
_start:
	call buf.read
	mov edx, eax
	call buf.write
	mov edi, 0
	call exit

global _start
