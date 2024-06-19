format elf64 executable 3

macro tc2 word_in, word_len {
	call	parser_next_word

	inc	[test_num]
	xor	eax, eax
	mov	al, [_blue.word_len]
	cmp	al, word_len
	jne	failure

	mov	ecx, eax
	mov	eax, word_in
	call	check_word
}

macro tc1 tib, tib_len, word_in, word_len {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0

	tc2	word_in, word_len
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
	tc1	space_a, 2, 1, 1
	tc1	a_space, 2, 0, 1
	tc1	abc, 3, 0, 3
	tc1	ws_abc_ws, 7, 2, 3

	tc1	toks_2, 3, 0, 1
	tc2	2, 1

	;tc1	toks_3, 20, 4, 4
	;tc2	10, 4
	;tc2	15, 6

	xor	edi, edi

exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

failure2:
	add	[test_num], 128
	jmp	failure

;
; expects
;	- word_len in ecx
;	- word_in in al
;
check_word:
	test	cl, cl
	jz	.done

	mov	rsi, [_blue.tib]
	add	esi, eax
	mov	rdi, _blue.word

	.loop:
	cmpsb
	jne	failure2

	dec	ecx
	jnz	.loop
	
	.done:
	ret

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
