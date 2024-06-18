format elf64 executable 3

macro tc num, tib, tib_len, tib_in, word_len {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], tib_in
	call	parser_next_word

	mov	edi, num
	mov	al, [_blue.word_len]
	cmp	al, word_len
	jne	exit
}

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "parser.inc"

entry $
	tc	1, nothing, nothing.length, 0, 0
	tc	2, just_ws, just_ws.length, 0, 0

	;tc	2, just_a_number, just_a_number.length, 0, 1

	xor	edi, edi

exit:
	mov	eax, 60
	syscall

segment readable

nothing:
	.length = $ - nothing

just_ws:
	db 32, 9, 10, 32
	.length = $ - just_ws

just_a_number:
	db '6'
	.length = $ - just_a_number
