
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
