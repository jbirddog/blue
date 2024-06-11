format elf64 executable 3

segment readable writeable executable

entry $
	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1a0
	mov	eax, 2
	syscall

	push rax
	push rax

	mov	rdi, rax
	mov	rsi, output
	mov	rdx, output.length
	mov	eax, 1
	syscall

	pop	rdi
	mov	esi, 0x1ed
	mov	eax, 91
	syscall

	pop	rdi
	mov	eax, 3
	syscall

	xor 	edi, edi
	mov 	eax, 60
	syscall
	
;
; https://kevinboone.me/elfdemo.html
;
output:
	.elf_header:
	db	0x7f, 0x45, 0x4c, 0x46	; magic number
	db	0x02			; 64 bit
	db	0x01			; little endian
	db	0x01			; elf version
	db	0x00			; target abi
	dq	0x00			; target abi version + 7 bytes undefined
	dw	0x02			; executable binary
	dw	0x3e			; amd64 architecture
	dd	0x01			; elf version
	db	0x78, 0x00, 0x40, 0x00	; start address
	dd	0x00
	dq	0x40			; offset to program header
	dq	0xc0			; offset to section header
	dd	0x00			; architecture flags
	dw	0x40			; size of header
	dw	0x38			; size of program header
	dw	0x01			; number of program headers
	dw	0x40			; size of section header
	dw	0x03			; number of section headers
	dw	0x02			; index if strtab section header

	assert $ - .elf_header = 0x40

	.program_header:
	dd	0x01			; entry type: loadable segment
	dd	0x05			; segment flags: RX
	dq	0x00			; offset within file
	db	0x00, 0x00, 0x40, 0x00	; load position in virtual memory
	dd	0x00
	db	0x00, 0x00, 0x40, 0x00	; load position in physical memory
	dd	0x00
	dd	0xb0			; size of the loaded section (file)
	dd	0x00
	dd	0xb0			; size of the loaded section (memory)
	dd	0x00
	db	0x00, 0x00, 0x20, 0x00	; alignment boundary for sections
	dd	0x00

	assert $ - .program_header = 0x38

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

	assert $ - .program_code = 0x2a

	.string:
	db	"Hello, world"
	db	0x0a, 0x00

	assert $ - .string = 0x0e

	.strtab:
	db	".shstrab\0.text"
	db	0x00

	assert $ - .strtab = 0x10

	.section_0:
	dq 	0x00, 0x00, 0x00, 0x00	; 64 bytes of 0s 
	dq 	0x00, 0x00, 0x00, 0x00

	assert $ - .section_0 = 0x40

	.section_1:
	dd 0x0a				; offset to name in strtab
	dd 0x01				; type: program data
	dd 0x06				; flags - executable | in memory
	dd 0x00
	db 0x78, 0x00, 0x40, 0x00	; addr in virtual memory of section
	dd 0x00
	dd 0x78				; offset in the file of this section
	dd 0x00
	dd 0x38				; size of this section in the file
	dd 0x00
	dq 0x00				; sh_link - not used
	dd 0x01				; alignment code (default??)
	dd 0x00
	dq 0x00				; sh_entsize - not used

	assert $ - .section_1 = 0x40

	.section_2:
	dd 0x00				; offset to name in strtab
	dd 0x03				; type: string table
	dd 0x00				; flags - none
	dd 0x00
	dd 0x00				; addr in virtual memory of section - not used
	dd 0x00
	dd 0xb0				; offset in the file of this section
	dd 0x00
	dd 0x10				; size of this section in the file
	dd 0x00
	dq 0x00				; sh_link - not used
	dd 0x01				; alignment code (default??)
	dd 0x00
	dq 0x00				; sh_entsize - not used

	assert $ - .section_2 = 0x40
	
	.length = $ - output

output_file:
	db "a.out", 0x00
	.length = $ - output_file
