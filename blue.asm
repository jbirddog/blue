format elf64 executable 3

segment readable writeable executable

entry $	
	xor 	edi, edi
	mov 	eax, 60
	syscall

;
; https://kevinboone.me/elfdemo.html
;
output:
	;
	; elf header 64 bytes
	;
	.elf_header:
	db	0x7f, 0x45, 0x4c, 0x46	; magic number
	db	0x02			; 64 bit
	db	0x01			; little endian
	db	0x01			; elf version
	db	0x00			; target abi
	db	0x00			; target abi version
	dd	0x00			; 7 bytes undefined
	db	0x00, 0x00, 0x00
	db	0x02, 0x00		; executable binary
	db	0x3e, 0x00		; amd64 architecture
	db	0x01, 0x00, 0x00, 0x00	; elf version
	db	0x78, 0x00, 0x40, 0x00	; start address
	dd	0x00
	db	0x40, 0x00, 0x00, 0x00	; offset to program header
	dd	0x00
	db	0xc0, 0x00, 0x00, 0x00	; offset to section header
	db	0x00, 0x00, 0x00, 0x00
	dd	0x00			; architecture flags
	db	0x40, 0x00		; size of header
	db	0x38, 0x00		; size of program header
	db	0x01, 0x00		; number of program headers
	db	0x40, 0x00		; size of section header
	db	0x03, 0x00		; number of section headers
	db	0x02, 0x00		; index if strtab section header

	assert $ - .elf_header = 64

	.program_header:
	db	0x01, 0x00, 0x00, 0x00	; entry type: loadable segment
	db	0x05, 0x00, 0x00, 0x00	; segment flags: RX
	dq	0x0			; offset within file
	db	0x00, 0x00, 0x40, 0x00	; load position in virtual memory
	dd	0x00
	db	0x00, 0x00, 0x40, 0x00	; load position in physical memory
	dd	0x00
	db	0xb0, 0x00, 0x00, 0x00	; size of the loaded section (file)
	dd	0x00
	db	0xb0, 0x00, 0x00, 0x00	; size of the loaded section (memory)
	dd	0x00
	db	0x00, 0x00, 0x20, 0x00	; alignment boundary for sections
	dd	0x00

	assert $ - .program_header = 56

	.program_code:
	db	0x48, 0xc7, 0xc0, 0x01	; mov rax, 1 - sys_write
	db	0x00, 0x00, 0x00
	db	0x48, 0xc7, 0xc7, 0x01	; mov rdi, 1 - stdout fd
	db	0x00, 0x00, 0x00
	db	0x48, 0xc7, 0xc6, 0xa2	; mov rsi, 0x4000a2 - location of string
	db	0x00, 0x40, 0x00
	db	0x48, 0xc7, 0xc2, 0x0d	; mov rdx, 13 - size of string
	db	0x00, 0x00, 0x00
	db	0x0f, 0x05		; syscall
	db	0x48, 0xc7, 0xc0, 0x3c	; mov rax, 60 - sys_exit
	db	0x00, 0x00, 0x00
	db	0x48, 0x31, 0xff	; xor rdi, rdi
	db	0x0f, 0x05		; syscall

	assert $ - .program_code = 42

	.string:
	db	0x48, 0x65, 0x6c, 0x6c	; string "Hello, world\n\0"
	db	0x6f, 0x2c, 0x20, 0x77
	db	0x6f, 0x72, 0x6c, 0x64
	db	0x0a, 0x00

	assert $ - .string = 14

	.strtab:
	db	0x2e, 0x73, 0x68, 0x73 ; ".shstrab\0.text\0"
	db	0x74, 0x72, 0x74, 0x61
	db	0x62, 0x00, 0x2e, 0x74
	db	0x65, 0x78, 0x74, 0x00

	assert $ - .strtab = 16

	.section_0:

	dq 0, 0, 0, 0			; 64 bytes of 0s 
	dq 0, 0, 0, 0

	assert $ - .section_0 = 64
	
output.length = $ - output
