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

	tc1	nothing, 0, 0, 0
	
	tc1	space, 1, 0, 0
	tc1	tab, 1, 0, 0
	tc1	newline, 1, 0, 0
	tc1	spaces, 2, 0, 0
	tc1	ws_4, 4, 0, 0

	;tc1	six, 1, 0, 1

	xor	edi, edi

exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

nothing		db 0
space		db 32
tab		db 9
newline		db 10
spaces		db 32, 32
ws_4		db 32, 9, 10, 32
six		db '6'
