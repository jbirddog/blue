
macro tc1 tib, tib_len, expected {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0

	t 'finds the expected word'

	call	parser_next_word
	call	dictionary_find
	
	cmp	rax, expected
	jne	failure

	ok
}

macro tc2 word, in_len, word_len {
	mov	rax, word
	call	word_input_stack_effects

	t 'has the expected number of input stack effects'
	
	cmp	ecx, in_len
	jne	failure
	push	rsi

	ok

	t 'has the expected pointer to input stack effects'

	pop	rsi
	cmp	rsi, word + _dictionary.word_offset + word_len
	jne	failure

	ok
}

dictionary_test:
	call dictionary_init
	
	
	t 'inits base and here correctly'
	
	mov	rax, [_dictionary.base]
	cmp	rax, [_dictionary.here]
	jne	failure

	ok

	t 'inits latest correctly'
	
	mov	rax, [_dictionary.latest]
	cmp	rax, _core_words.latest
	jne	failure

	ok
	
	t 'b, writes a byte'

	mov	al, 123
	call	b_comma
	
	mov	rax, [_code_buffer.base]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 1
	jne	failure
	push	rax

	ok

	t 'b, writes the correct value'

	pop	rax
	mov	rax, [rax]
	cmp	al, 123
	jne	failure

	ok

	t 'd, writes a dword'
	
	mov	eax, 123456
	call	d_comma

	mov	rax, [_code_buffer.base]
	inc	rax
	mov	rcx, [_code_buffer.here]
	sub	rcx, rax
	cmp	ecx, 4
	jne	failure
	push	rax

	ok

	t 'd, writes the correct value'

	pop	rax
	mov	rax, [rax]
	cmp	eax, 123456
	jne	failure

	ok

	tc1	unknown, 4, 0
	tc1	word_b_comma, 2, _core_words.b_comma
	tc1	word_d_comma, 2, _core_words.d_comma
	tc1	word_base, 4, _core_words.base

	tc2	_core_words.b_comma, 1, 8

	call	_test_new_entry

	tc1	unknown, 4, 0
	tc1	word_b_comma, 2, _core_words.b_comma
	tc1	word_d_comma, 2, _core_words.d_comma
	tc1	word_base, 4, _core_words.base
	
	call	dictionary_deinit
	
	ret

_test_new_entry:
	t 'can create new entry'

	push	[_dictionary.latest]
	call	_create_entry

	pop	rax
	mov	rax, [rax]
	cmp	rax, [_dictionary.latest]
	je	failure

	ok

	t 'new entry is hidden'

	mov	rax, [_dictionary.latest]
	mov	rax, [rax]
	
	cmp	al, DE_HIDDEN
	jne	failure

	ok

	t 'new entry has pointer to previous latest'

	mov	rax, [_dictionary.latest]
	add	rax, _dictionary.prev_word_offset
	mov	rax, [rax]

	mov	rsi, _core_words.latest
	cmp	rax, rsi
	jne	failure

	ok

	t 'new entry has pointer to code buffer'

	mov	rax, [_dictionary.latest]
	add	rax, _dictionary.code_offset
	mov	rax, [rax]
	cmp	rax, [_code_buffer.here]
	jne	failure
	
	ok

	ret

	
unknown		db '!@#$'
word_b_comma	db 'b,'
word_d_comma	db 'd,'
word_base	db 'base'
