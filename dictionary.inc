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
	assert $ - .b_comma = 40
	
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
	assert $ - .d_comma = 40

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

	.loop:
	push	rdi

	test	byte [edi], DE_HIDDEN
	jnz	.next

	inc	edi
	mov	rsi, _blue.word_len
	mov	ecx, esi

	cmpsb
	jne	.next

	.next:
	pop	rdi
	add	edi, _dictionary.prev_word_offset
	mov	rdi, [rdi]
	test	rdi, rdi
	jz	.done
	jmp	.loop

	.done:
	ret
