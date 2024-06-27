format elf64 executable 3

macro tc1 tib, tib_len, expected {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0

	call	parser_next_word
	call	dictionary_find

	inc	[test_num]
	cmp	rax, expected
	jne	failure
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "dictionary.inc"
include "parser.inc"

entry $
	mov	[test_num], 0

	call dictionary_init
	
	inc	[test_num]
	mov	rax, [_dictionary.base]
	cmp	rax, [_dictionary.here]
	jne	failure
	
	inc	[test_num]
	mov	rax, [_dictionary.latest]
	cmp	rax, _core_words.latest
	jne	failure

	tc1	unknown, 4, 0
	tc1	b_comma, 2, _core_words.b_comma
	tc1	d_comma, 2, _core_words.d_comma

	mov	rax, _core_words.b_comma
	call	word_input_stack_effects

	inc	[test_num]
	cmp	ecx, 1
	jne	failure

	inc	[test_num]
	cmp	rax, _core_words.b_comma + _dictionary.word_offset + 8
	jne	failure
	
	call	dictionary_deinit

	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

unknown		db '!@#$'
b_comma		db 'b,'
d_comma		db 'd,'
