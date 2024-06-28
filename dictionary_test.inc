
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

	tc1	unknown, 4, 0
	tc1	b_comma, 2, _core_words.b_comma
	tc1	d_comma, 2, _core_words.d_comma

	tc2	_core_words.b_comma, 1, 8
	
	call	dictionary_deinit

	ret

unknown		db '!@#$'
b_comma		db 'b,'
d_comma		db 'd,'
