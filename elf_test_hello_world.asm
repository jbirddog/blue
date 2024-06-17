format elf64 executable 3

include "linux.inc"
include "elf.inc"

segment readable writeable

fstat_buffer:
	rb	48
	.file_size:
	rq	1
	rb	88

program_code:
	.entry_offset = $ - program_code
	db	0x48, 0xc7, 0xc0	; mov rax, 1 - sys_write
	dd	0x01
	db	0x48, 0xc7, 0xc7	; mov rdi, 1 - stdout fd
	dd	0x01
	db	0x48, 0xc7, 0xc6	; mov rsi, 0x4000a2 - location of string
	dd	0x4000a2
	db	0x48, 0xc7, 0xc2	; mov rdx, 13 - size of string
	dd	0x0d
	db	0x0f, 0x05		; syscall
	db	0x48, 0xc7, 0xc0	; mov rax, 60 - sys_exit
	dd	0x3c
	db	0x48, 0x31, 0xff	; xor rdi, rdi
	db	0x0f, 0x05		; syscall

	db	"Hello, world"
	db	0x0a, 0x00

	.length = $ - program_code

segment readable executable

expected_output_size = elf_binary_wrapper_length + program_code.length

assert expected_output_size = 384

output_file:
	db	"elf_test_hello_world.out"
	db	0x00

execve_args:
	dq	output_file
	dq	0x0

entry $	
	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, program_code
	mov	eax, program_code.entry_offset
	mov	ecx, program_code.length
	call	elf_binary_write

	mov	rsi, fstat_buffer
	mov	eax, SYS_FSTAT
	syscall
	
	cmp	qword [fstat_buffer.file_size], expected_output_size
	jne	failure
	
	mov	eax, SYS_CLOSE
	syscall

    	mov 	rdi, output_file
    	mov 	rsi, execve_args
    	xor 	rdx, rdx
	mov	eax, SYS_EXECVE
    	syscall

failure:
	mov	rdi, 1
	mov	eax, SYS_EXIT
	syscall
