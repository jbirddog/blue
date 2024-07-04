
blue_code:
	db	'16 base '
	
	;db	0x48, 0xc7, 0xc0	; mov rax, 1 - sys_write
	;dd	0x01
	;db	0x48, 0xc7, 0xc7	; mov rdi, 1 - stdout fd
	;dd	0x01
	;db	0x48, 0xc7, 0xc6	; mov rsi, 0x4000a2 - location of string
	;dd	0x4000a2
	;db	0x48, 0xc7, 0xc2	; mov rdx, 13 - size of string
	;dd	0x0d
	;db	0x0f, 0x05		; syscall
	;db	0x48, 0xc7, 0xc0	; mov rax, 60 - sys_exit
	;dd	0x3c
	;db	0x48, 0x31, 0xff	; xor rdi, rdi
	;db	0x0f, 0x05		; syscall

	;db	"Hello, world"
	;db	0x0a, 0x00

	.length = $ - blue_code

expected_output_size = 384

elf_test:	
	call	kernel_init
	
	mov	eax, [_blue.entry]
	mov	ecx, blue_code.length
	call	elf_binary_calculate_fields

	t 'start address is correct'
	
	cmp	qword [elf_header.start_address], 0x400078
	jne	failure

	ok

	t 'section header offset is correct'
	
	cmp	qword [elf_header.section_header_offset], 0xc0
	jne	failure

	ok

	t 'size in file is correct'
	
	cmp	qword [program_header.size_in_file], 0xb0
	jne	failure

	ok

	t 'size in memory is correct'
	
	cmp	qword [program_header.size_in_memory], 0xb0
	jne	failure

	ok

	t 'section header address is correct'
	
	cmp	qword [program_code_section_header.address], 0x400078
	jne	failure

	ok

	t 'section header offset is correct'
	
	cmp	qword [program_code_section_header.offset], 0x78
	jne	failure

	ok

	t 'section header size is correct'

	cmp	qword [program_code_section_header.size], 0x38
	jne	failure

	ok

	t 'section header offset is correct'
	cmp	qword [shstrtab_section_header.offset], 0xb0
	jne	failure

	ok

	t 'section header size is correct'

	cmp	qword [shstrtab_section_header.size], 0x10
	jne	failure

	ok

	t 'can write an elf binary of the expected size'

	mov	rsi, blue_code
	mov	ecx, blue_code.length
	xor	eax, eax

	call	kernel_loop

	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, [_code_buffer.base]
	mov	eax, [_blue.entry]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rsi
	call	elf_binary_write

	mov	rsi, fstat_buffer
	mov	eax, SYS_FSTAT
	syscall
	
	mov	eax, SYS_CLOSE
	syscall

	cmp	qword [fstat_buffer.file_size], expected_output_size
	jne	failure

	ok

	call	kernel_deinit
	
	ret

execve_hello_world:
    	mov 	rdi, output_file
    	mov 	rsi, execve_args
    	xor 	rdx, rdx
	mov	eax, SYS_EXECVE
    	syscall

output_file:
	db	"elf_test_hello_world.out"
	db	0x00

execve_args:
	dq	output_file
	dq	0x0
