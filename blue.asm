format elf64 executable 3

segment readable writeable

_data_stack:
	.length = 4096
	.base dq 1
	.here dq 1

segment readable

error:
	.failed_to_mmap db 'failed to mmap', 10
	
segment readable executable

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
	;; : mmap ( fd:r8d len:esi addr:edi off:r9d prot:edx flags:r10d -- buf:eax ) 9 syscall unwrap ;
	;; : munmap ( addr:edi len:esi -- ) 11 syscall ordie
	xor edi, edi
	mov r8d, -1
	xor r9d, r9d
	mov r10d, .map_anonymous or .map_private
	mov eax, 9
	syscall

	cmp eax, 0
	jle .error
	ret

	.error:
	mov edi, 17
	mov eax, 60
	syscall

	.unmap:
	mov eax, 11
	syscall
	ret

data_stack:
	.init:
	mov esi, _data_stack.length
	mov edx, mmap.prot_rw
	call mmap.buffer
	
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
	;; call data_stack.init
	;; call data_stack.deinit

	mov rdi, 0
	mov rsi, 4096
	mov rdx, 3
	mov r10, 34
	mov r8, -1
	mov r9, 0
	mov rax, 9
	syscall

	cmp rax, 0
	
	mov rdi, rax
	mov rsi, 4096
	mov eax, 11
	syscall
	
	xor edi, edi
	mov rdi, rax
	mov eax, 60
	syscall
