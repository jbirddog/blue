PROT_READ = 1
PROT_WRITE = 2
PROT_EXEC = 4

PROT_RW = PROT_READ or PROT_WRITE
PROT_RWX = PROT_RW or PROT_EXEC

MAP_ANONYMOUS = 32
MAP_PRIVATE = 2

syscall_err:
	neg eax
	mov edi, eax
	mov eax, 60
	syscall
	
mmap:	
	.buffer:
	xor edi, edi
	mov r8d, -1
	xor r9d, r9d
	mov r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov eax, 9
	syscall

	cmp rax, 0
	jl syscall_err
	ret

	.unmap:
	mov eax, 11
	syscall
	
	cmp rax, 0
	jne syscall_err
	ret

macro mmap_buffer len, prot {
	mov esi, len
	mov edx, prot
	call mmap.buffer
}
