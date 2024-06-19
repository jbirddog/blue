format elf64 executable 3

macro tc1 tib, tib_len, tib_in, word_len {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], tib_in
	call	parser_next_word

	inc	[test_num]
	mov	al, [_blue.word_len]
	cmp	al, word_len
	jne	failure
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "parser.inc"

entry $
	mov	[test_num], 0
	
	tc1	nothing, nothing.length, 0, 0
	
	tc1	just_space, just_space.length, 0, 0
	tc1	just_tab, just_tab.length, 0, 0
	tc1	just_newline, just_newline.length, 0, 0
	tc1	some_ws, some_ws.length, 0, 0

	;tc1	just_a_number, just_a_number.length, 0, 1

	xor	edi, edi

exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

nothing:
	.length = $ - nothing

just_space:
	db 32
	.length = $ - just_space

just_tab:
	db 9
	.length = $ - just_tab

just_newline:
	db 10
	.length = $ - just_newline

some_ws:
	db 32, 9, 10, 32
	.length = $ - some_ws

just_a_number:
	db '6'
	.length = $ - just_a_number
