format elf64 executable 3

include "const.inc"
	
segment readable writeable

_code_buffer:
	.length = 4096
	.base dq 1
	.here dq 1

_data_stack:
	.length = 4096
	.base dq 1
	.here dq 1

_dictionary:
	.length = 4096
	.base dq 1
	.here dq 1
	.latest dq 1
	
segment readable executable

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

code_buffer:
	.init:
	mmap_buffer _code_buffer.length, PROT_RWX
	
	mov [_code_buffer.base], rax
	mov [_code_buffer.here], rax
	ret

	.deinit:
	mov esi, _code_buffer.length
	mov rdi, [_code_buffer.base]
	call mmap.unmap
	ret
	

data_stack:
	.init:
	mmap_buffer _data_stack.length, PROT_RW
	
	mov [_data_stack.base], rax
	mov [_data_stack.here], rax
	ret

	.deinit:
	mov esi, _data_stack.length
	mov rdi, [_data_stack.base]
	call mmap.unmap
	ret
	
	.push:
	mov rdi, [_data_stack.here]
	stosq
	mov [_data_stack.here], rdi
	ret

	.pop:
	mov rsi, [_data_stack.here]
	cmp rsi, [_data_stack.base]
	jle .underflow
	std
	lodsq
	mov [_data_stack.here], rsi
	lodsq
	cld
	ret

	.underflow:
	mov edi, 3
	mov eax, 60
	syscall

dictionary:
	;
	; entry:
	;
	; 08 - 1 byte flags
	;    - 1 byte word length
	;    - 6 bytes first chars
	; 08 - prev addr
	; 08 - code addr
	; 08 - 1 byte length of remaining word chars
	;    - 1 byte length of code
	;    - 6 bytes reserved
	; ?? - remaining word chars
	; ?? - stack effects
	;

	.init:
	mmap_buffer _dictionary.length, PROT_RW

	mov [_dictionary.base], rax
	mov [_dictionary.here], rax
	mov [_dictionary.latest], 0
	ret

	.deinit:
	mov esi, _dictionary.length
	mov rdi, [_dictionary.base]
	call mmap.unmap
	ret
	
entry $
	call code_buffer.init
	call data_stack.init
	call dictionary.init

	mov eax, 6
	call data_stack.push
	call data_stack.pop

	mov eax, 7
	call data_stack.push
	call data_stack.pop

	call code_buffer.deinit
	call data_stack.deinit
	call dictionary.deinit
	
	xor edi, edi
	mov edi, eax
	mov eax, 60
	syscall
