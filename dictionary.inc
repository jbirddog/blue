;
; entry:
;
; 08	- 1 byte flags
;	- 1 byte word len
;	- 1 byte input stack effects len
;	- 5 bytes reserved
; 08	- prev addr
; 08	- code addr
; ??	- word chars (bytes padded to quad)
; ??	- stack effects (quads)
;

DE_HIDDEN		= 1
DE_IMMEDIATE		= 2

FLAGS_OFFSET		= 0
FLAGS_MASK		= 0xff

WORD_LEN_OFFSET		= 0x08
WORD_LEN_MASK		= 0x00ff

IN_EFFECTS_LEN_OFFSET	= 0x10
IN_EFFECTS_LEN_MASK	= 0x0000ff

_core_words:
	.b_comma:
	db	0, 2, 1, 0
	dd	0
	dq	0
	dq	b_comma
	dq	'b,'
	dq	_AL
	; TODO: clobbers rdi
	
	.d_comma:
	db	0, 2, 1, 0
	dd	0
	dq	.b_comma
	dq	d_comma
	dq	'd,'
	dq	_EAX
	; TODO: clobbers rdi
	
	.latest:
	.base:
	db	0, 4, 1, 0
	dd	0
	dq	.d_comma
	dq	base
	dq	'base'
	dq	_AL

assert ($ - _core_words) and 7 = 0

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

	mov	rax, [rdi]

	test	al, DE_HIDDEN
	jnz	.hidden

	inc	rdi
	mov	rsi, _blue.word_len
	mov	ecx, [esi]
	
	lodsb
	cmp	al, byte [edi]
	jne	.next

	add	rdi, _dictionary.word_offset - 1
	
	.check_word:
	lodsb
	cmp	al, byte [edi]
	jne	.next

	inc	rdi
	dec	ecx
	js	.check_word

	pop	rax
	jmp	.done

	.hidden:
	
	.next:
	pop	rdi
	add	rdi, _dictionary.prev_word_offset
	mov	rdi, [rdi]

	test	rdi, rdi
	jnz	.find

	xor	eax, eax
	
	.done:
	ret

;
; expects
;	- word in rax
;
_padded_word_length:
	lea	ecx, [eax + 1]
	mov	ecx, [ecx]
	and	ecx, 0xff
	
	add	ecx, 7
	and	ecx, -8

	ret

;
; expects
;	- word in rax
;
word_input_stack_effects:
	lea	esi, [eax + 2]
	mov	esi, [esi]
	and	esi, 0xff

	call	_padded_word_length
	xchg	esi, ecx

	lea	esi, [eax + _dictionary.word_offset + esi]
	
	ret

;
; expects
;	- value in al
;
b_comma:
	mov	rdi, [_code_buffer.here]
	stosb
	mov	[_code_buffer.here], rdi
	ret

;
; expects
;	- value in eax
;
d_comma:
	mov	rdi, [_code_buffer.here]
	stosd
	mov	[_code_buffer.here], rdi
	ret

;
; expects
;	- value in al
;
base:
	mov	[_blue.base], al
	ret

_bad_pad:
	die	ERR_BAD_PAD

_check_pad:
	mov	rax, [_dictionary.here]
	mov	rdi, [_dictionary.latest]
	cmp	rax, rdi
	je	_bad_pad
	
	sub	rax, rdi
	and	rax, 7
	jnz	_bad_pad

	ret
	
_create_entry:
	mov	rdi, [_dictionary.here]
	push	rdi

	mov	eax, DE_HIDDEN
	stosq

	mov	rax, [_dictionary.latest]
	stosq

	mov	rax, [_code_buffer.here]
	stosq

	mov	[_dictionary.here], rdi
	
	pop	rdi
	mov	[_dictionary.latest], rdi

	call	_check_pad
	
	ret

_name_entry:
	call	parser_next_word
	xor	eax, eax
	mov	al, [_blue.word_len]
	test	al, al
	jz	.no_word

	mov	rdi, [_dictionary.latest]
	inc	rdi
	stosb

	mov	ecx, eax
	mov	ebx, eax
	add	ebx, 7
	and	ebx, -8
	sub	ebx, ecx

	mov	rdi, [_dictionary.here]
	mov	rsi, _blue.word

	.loop:
	movsb

	dec	ecx
	jnz	.loop

	mov	ecx, ebx
	test	ecx, ecx
	jz	.done
	
	xor	eax, eax
	
	.pad:
	stosb

	dec	ecx
	jnz	.pad

	.done:
	mov	[_dictionary.here], rdi
	call	_check_pad
	
	ret

	.no_word:
	die	ERR_NO_WORD
