format elf64 executable 3
	
segment readable writeable

_data_stack:
	.length = 4096
	.base dq 1
	.here dq 1
	
segment readable executable

syscall_err:
	neg eax
	mov edi, eax
	mov eax, 60
	syscall
	
mmap:
	.prot_read = 1
	.prot_write = 2
	.prot_exec = 4

	.prot_rw = .prot_read or .prot_write
	.prot_rwx = .prot_rw or .prot_exec

	.map_anonymous = 32
	.map_private = 2
	.map_failed = -1
	
	.buffer:
	xor edi, edi
	mov r8d, -1
	xor r9d, r9d
	mov r10d, .map_anonymous or .map_private
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

data_stack:
	.init:
	mmap_buffer _data_stack.length, mmap.prot_rw
	
	mov [_data_stack.base], rax
	mov [_data_stack.here], rax
	ret

	.deinit:
	mov esi, _data_stack.length
	mov rdi, [_data_stack.base]
	call mmap.unmap
	ret
	
	.push:
	mov rsi, [_data_stack.here]
	stosq
	mov [_data_stack.here], rsi
	ret
	
entry $
	call data_stack.init
	;; call data_stack.deinit
	
	mov rdi, rax
	mov rsi, 4096
	mov eax, 11
	syscall

	cmp rax, 0
	jl bad

	xor edi, edi
	mov eax, 60
	syscall

bad:	
	mov edi, 1
	mov eax, 60
	syscall

bad2:	
	mov edi, 2
	mov eax, 60
	syscall
