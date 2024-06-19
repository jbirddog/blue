format elf64 executable 3

macro tc2 word_len {
	call	parser_next_word

	inc	[test_num]
	mov	al, [_blue.word_len]
	cmp	al, word_len
	jne	failure
}

macro tc1 tib, tib_len, tib_in, word_len {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], tib_in

	tc2	word_len
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "parser.inc"

entry $
	mov	[test_num], 0

	tc1	nothing, 0, 0, 0
	
	tc1	space, 1, 0, 0
	tc1	tab, 1, 0, 0
	tc1	newline, 1, 0, 0
	tc1	spaces, 2, 0, 0
	tc1	ws_4, 4, 0, 0

	tc1	six, 1, 0, 1
	tc1	space_a, 2, 0, 1
	tc1	a_space, 2, 0, 1
	tc1	abc, 3, 0, 3
	tc1	ws_abc_ws, 7, 0, 3

	tc1	toks_2, 3, 0, 1
	tc2	1

	tc1	toks_3, 20, 0, 4
	tc2	4
	tc2	6

bye:
	xor	edi, edi

exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	;mov	edi, [_blue.tib_in]
	;mov	dil, [_blue.word_len]
	jmp	exit

segment readable

nothing		db 0
space		db 32
tab		db 9
newline		db 10
spaces		db 32, 32
ws_4		db 32, 9, 10, 32
six		db '6'
space_a		db ' a'
a_space		db 'a '
abc		db 'abc'
ws_abc_ws	db 10, 32, 'abc', 9, 10
toks_2		db 'a b'
toks_3		db '   some  more tokens'
