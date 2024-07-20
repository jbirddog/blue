;
; entry:
;
; 08	- 1 byte flags
;	- 1 byte word len
;	- 1 byte input stack effects len
;	- 1 byte output stack effects len
;	- 4 bytes reserved
; 08	- prev addr
; 08	- code addr
; ??	- word chars (bytes padded to quad)
; ??	- stack effects (quads)
;

DE_HIDDEN		= 00000001b
DE_IMMEDIATE		= 00000010b
DE_CORE			= 00000100b
DE_SE_KNOWN		= 00001000b

FLAGS_OFFSET		= 0
FLAGS_MASK		= 0xff

WORD_LEN_OFFSET		= 0x08
WORD_LEN_MASK		= 0x00ff

IN_EFFECTS_LEN_OFFSET	= 0x10
IN_EFFECTS_LEN_MASK	= 0x0000ff

macro __w word, word_len, flags, code, ise_len, ose_len {
	.##code:
	db	flags or DE_CORE, word_len, ise_len, ose_len
	dd	0
	dq	_core_words.prev_word
	dq	code
	db	word

	times ((word_len + 7) and -8) - word_len db 0

	_core_words.prev_word = .##code
}

macro _w word, word_len, code, ise_len, ose_len {
	__w	word, word_len, 0, code, ise_len, ose_len
}

macro _wi word, word_len, code, ise_len, ose_len {
	__w	word, word_len, DE_IMMEDIATE, code, ise_len, ose_len
}

macro _ise e {
	dq	e
}

macro _ose e {
	dq	e
}

_core_words:
	.prev_word = 0

	_wi	'ecx', 3, se_reg.ecx, 0, 0
	_wi	'eax', 3, se_reg.eax, 0, 0

	.se_reg_latest = .prev_word
	.prev_word = 0

	_wi	'--', 2, seX_o_parse, 0, 0
	_wi	'))', 2, seX_parse_end, 0, 0

	.se_parse_latest = .prev_word
	.prev_word = 0
	
	_w	'b,', 2, b_comma, 1, 0
	_ise	_AL

	_w	'd,', 2, d_comma, 1, 0
	_ise	_EAX

	_w	'q,', 2, q_comma, 1, 0
	_ise	_RAX

	_wi	':', 1, colon, 0, 0
	_wi	';', 1, semi, 0, 0

	_w	'base', 4, base, 1, 0
	_ise	_AL

	_wi	'entry', 5, _entry, 0, 0
	_wi	'immediate', 9, immediate, 0, 0

	_wi	'((', 2, seX_i_parse, 0, 0

	.latest = .prev_word

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

_find_from:
	.find:
	push	rdi

	mov	rax, [rdi]

	test	al, DE_HIDDEN
	jnz	.hidden

	inc	rdi
	mov	rsi, _blue.word_len
	mov	ecx, [esi]
	
	lodsb
	cmp	al, byte [rdi]
	jne	.next

	add	rdi, _dictionary.word_offset - 1
	
	.check_word:
	lodsb
	cmp	al, byte [rdi]
	jne	.next

	inc	rdi
	dec	cl
	jnz	.check_word

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
	lea	rcx, [rax + 1]
	mov	rcx, [rcx]
	and	ecx, 0xff
	
	add	ecx, 7
	and	ecx, -8

	ret

;
; expects
;	- word in rax
;
word_input_stack_effects:
	lea	rsi, [rax + 2]
	mov	rsi, [rsi]
	and	esi, 0xff

	call	_padded_word_length
	xchg	rsi, rcx

	lea	rsi, [rax + _dictionary.word_offset + rsi]
	
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
;	- value in rax
;
q_comma:
	mov	rdi, [_code_buffer.here]
	stosq
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

_reveal:
	mov	rdi, [_dictionary.latest]
	mov	al, byte [rdi]
	xor	al, DE_HIDDEN
	stosb

	ret

colon:
	call	_create_entry
	call	_name_entry
	
	mov	[_blue.mode], COMPILE
	
	ret

semi:
	mov	al, 0xc3
	call	b_comma

	call	_reveal

	mov	[_blue.mode], INTERPRET

	ret

_entry:
	mov	rax, [_dictionary.latest]
	add	rax, _dictionary.code_offset
	mov	rax, [rax]
	sub	rax, [_code_buffer.base]
	mov	[_blue.entry], eax

	ret

immediate:
	mov	rdi, [_dictionary.latest]
	mov	al, byte [rdi]
	or	al, DE_IMMEDIATE
	stosb

	ret

se_bad:
	die	ERR_BAD_SE
	
seX_i_parse:
	call	parser_next_word
	cmp	[_blue.word_len], 0
	je	se_bad

	mov	rdi, _core_words.se_parse_latest
	call	_find_from

	cmp	rax, _core_words.seX_o_parse
	je	seX_o_parse

	call	parser_next_word
	cmp	[_blue.word_len], 0
	je	se_bad

	mov	rdi, _core_words.se_reg_latest
	call	_find_from

	test	rax, rax
	jz	se_bad

	add	rax, _dictionary.code_offset
	call	qword [rax]
	
	jmp	seX_i_parse
	
seX_o_parse:
	call	parser_next_word
	cmp	[_blue.word_len], 0
	je	se_bad

	mov	rdi, _core_words.se_parse_latest
	call	_find_from

	cmp	rax, _core_words.seX_parse_end
	je	seX_parse_end

	jmp	se_bad
	
seX_parse_end:
	mov	rdi, [_dictionary.latest]
	mov	al, byte [rdi]
	or	al, DE_SE_KNOWN
	stosb

	mov	rax, [_dictionary.latest]
	call	push_flow_in

	ret

se_reg:
macro _se_reg reg, _REG {
	.##reg:
	mov	rax, _REG
	mov	rdi, [_dictionary.here]
	stosq
	mov	[_dictionary.here], rdi

	mov	rdi, [_dictionary.latest]
	add	rdi, 2
	mov	al, byte [rdi]
	inc	al
	stosb
	
	ret
}
	
	_se_reg	eax, _EAX
	_se_reg	ecx, _ECX
