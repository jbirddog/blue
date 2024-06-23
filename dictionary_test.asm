format elf64 executable 3

macro tc1 tib, tib_len {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0

	call	parser_next_word
	call	dictionary_find

	inc	[test_num]
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

	; test dictionary init's properly
	
	inc	[test_num]
	mov	rax, [_dictionary.base]
	cmp	rax, [_dictionary.here]
	jne	failure
	
	inc	[test_num]
	mov	rax, [_dictionary.latest]
	cmp	rax, _core_words.latest
	jne	failure

	tc1	d_comma, 2
	
	call	dictionary_deinit

	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

b_comma		db 'b,'
d_comma		db 'd,'
