format elf64 executable 3

macro tc1 tib, tib_len, base, result, expected {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0
	mov	byte [_blue.base], base

	call	parser_next_word
	call	to_number

	inc	[test_num]
	cmp	eax, result
	jne	failure

	inc	[test_num]
	cmp	edi, expected
	jne	failure	
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "parser.inc"
include "to_number.inc"

entry $
	mov	[test_num], 0
	mov	[_blue.base], 10

	tc1	not_number, 4, 10, FAILURE, 0
	tc1	zero, 1, 10, SUCCESS, 0
	tc1	one, 1, 10, SUCCESS, 1
	tc1	thirteen, 2, 10, SUCCESS, 13
	tc1	thousand, 4, 10, SUCCESS, 1000

	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

not_number	db '!@#$'
zero		db '0'
one		db '1'
thirteen	db '13'
thousand	db '1000'
