;
; entry:
;
; 08	- 1 byte flags
;	- 1 byte word len
;	- 6 bytes reserved
; 08	- prev addr
; 08	- code addr
; ??	- word chars (padded to dq)
; ??	- stack effects
;

DE_HIDDEN	= 1
DE_IMMEDIATE	= 2

_core_words:
	.b_comma:
	db	DE_IMMEDIATE
	db	2
	dw	0
	dd	0
	dq	0
	dq	_core_code.b_comma
	dq	'b,'
	dq	0 ; TODO: stack effects (( b al -- | rdi ))
	
	.latest:
	.d_comma:
	db	DE_IMMEDIATE
	db	2
	dw	0
	dd	0
	dq	.b_comma
	dq	_core_code.d_comma
	dq	'd,'
	dq	0 ; TODO: stack effects (( d ax -- | rdi ))

dictionary_init:
	mov	esi, _dictionary.length
	mov	edx, PROT_RW
	call	mmap_buffer

	mov	rdi, _dictionary.base
	stosq
	stosq
	
	mov	[_dictionary.latest], _core_words.latest

	ret

dictionary_deinit:
	mov	esi, _dictionary.length
	mov	rdi, [_dictionary.base]
	mov	eax, SYS_MUNMAP
	syscall
	
	ret

;
; expects
;	- properly configured blue structure with non zero word len
;
dictionary_find:
	mov	rdi, [_dictionary.latest]

	.find:
	push	rdi

	test	byte [edi], DE_HIDDEN
	jnz	.next

	inc	edi
	mov	rsi, _blue.word_len
	mov	ecx, [esi]
	
	lodsb
	cmp	al, byte [edi]
	jne	.next

	add	edi, _dictionary.word_offset - 1
	
	.check_word:
	lodsb
	cmp	al, byte [edi]
	jne	.next

	inc	edi
	dec	ecx
	js	.check_word

	pop	rax
	jmp	.done
	
	.next:
	pop	rdi
	add	edi, _dictionary.prev_word_offset
	mov	rdi, [rdi]

	test	rdi, rdi
	jnz	.find

	xor	eax, eax
	
	.done:
	ret