	
;
; adapted from https://kevinboone.me/elfdemo.html
;

elf_binary:
	.base_address = 0x400000

elf_binary_headers:
elf_header:
	db	0x7f, 0x45, 0x4c, 0x46	; magic number
	db	0x02			; 64 bit
	db	0x01			; little endian
	db	0x01			; elf version
	db	0x00			; target abi	
	dq	0x00			; target abi version + 7 bytes undefined
	dw	0x02			; executable binary
	dw	0x3e			; amd64 architecture
	dd	0x01			; elf version
	.start_address:
	dq	-0x01			; start address
	dq	0x40			; offset to program header
	.section_header_offset:
	dq	-0x01			; offset to section header
	dd	0x00			; architecture flags
	dw	0x40			; size of header
	dw	0x38			; size of program header
	dw	0x01			; number of program headers
	dw	0x40			; size of section header
	dw	0x03			; number of section headers
	dw	0x02			; index of strtab section header

	.length = $ - elf_header
	assert .length = 0x40

program_header:
	dd	0x01			; entry type: loadable segment
	dd	0x05			; segment flags: RX
	dq	0x00			; offset within file
	dq	elf_binary.base_address	; load position in virtual memory
	dq	elf_binary.base_address	; load position in physical memory
	.sizes:
	.size_in_file:
	dq	-0x01			; size of the loaded section (file)
	.size_in_memory:
	dq	-0x01			; size of the loaded section (memory)
	dq	0x200000		; alignment boundary for sections

	.length = $ - program_header
	assert .length = 0x38

shstrtab:
	db	".shstrtab"
	db	0x00
	db	".text"
	db	0x00

	.length = $ - shstrtab
	assert .length = 0x10

elf_binary_section_headers:
section_header_0:
	dq 	0x00, 0x00, 0x00, 0x00	; 64 bytes of 0s 
	dq 	0x00, 0x00, 0x00, 0x00

	.length = $ - section_header_0
	assert .length = 0x40

program_code_section_header:
	dd	0x0a			; offset to name in shstrtab
	dd 	0x01			; type: program data
	dq 	0x06			; flags - executable | in memory
	.address:
	dq 	-0x01			; addr in virtual memory of section
	.offset:
	dq 	-0x01			; offset in the file of this section
	.size:
	dq 	-0x01			; size of this section in the file
	dq 	0x00			; sh_link - not used
	dq 	0x01			; alignment code (default??)
	dq 	0x00			; sh_entsize - not used

	.length = $ - program_code_section_header
	assert .length = 0x40

shstrtab_section_header:
	dd 	0x00			; offset to name in shstrtab
	dd 	0x03			; type: string table
	dq 	0x00			; flags - none
	dq 	0x00			; addr in virtual memory of section - not used
	.offset:
	dq 	-0x01			; offset in the file of this section
	.size:
	dq 	-0x01			; size of this section in the file
	dq 	0x00			; sh_link - not used
	dq 	0x01			; alignment code (default??)
	dq 	0x00			; sh_entsize - not used

	.length = $ - shstrtab_section_header
	assert .length = 0x40
	
elf_binary_wrapper_length = $ - elf_binary
elf_binary_headers_length = elf_header.length + program_header.length
elf_binary_section_headers_length = $ - elf_binary_section_headers
elf_binary_section_headers_offset = elf_binary_section_headers - elf_binary 
