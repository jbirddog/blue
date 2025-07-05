
MAP_ANONYMOUS = 32
MAP_PRIVATE = 2

PAGE_SIZE = 4096

PROT_READ = 1
PROT_WRITE = 2
PROT_EXEC = 4

PROT_RW = PROT_READ or PROT_WRITE
PROT_RWX = PROT_RW or PROT_EXEC

SYS_EXIT = 60
SYS_MMAP = 9

mmap_rwx_buf:
	mov	esi, PAGE_SIZE
	mov	edx, PROT_RWX
	
	xor	edi, edi
	mov	r8d, -1
	xor	r9d, r9d
	mov	r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov	eax, SYS_MMAP
	syscall

	ret
