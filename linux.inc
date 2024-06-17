
SYS_WRITE 	= 1
SYS_OPEN 	= 2
SYS_CLOSE 	= 3
SYS_FSTAT	= 5
SYS_MMAP	= 9
SYS_MUNMAP	= 11
SYS_EXECVE 	= 59
SYS_EXIT 	= 60

PROT_READ	= 1
PROT_WRITE	= 2
PROT_EXEC	= 4

PROT_RW		= PROT_READ or PROT_WRITE
PROT_RWX	= PROT_RW or PROT_EXEC

MAP_ANONYMOUS	= 32
MAP_PRIVATE	= 2

;
; expects
;	- buffer length in esi
;	- buffer prot flags in edx
;
mmap_buffer:
	xor	edi, edi
	mov	r8d, -1
	xor	r9d, r9d
	mov	r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov	eax, SYS_MMAP
	syscall

	ret
