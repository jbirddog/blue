
macro tc1 tib, tib_len, result, expected {
	mov	[_blue.tib], tib
	mov	[_blue.tib_len], tib_len
	mov	[_blue.tib_in], 0

	call	parser_next_word
	call	to_number

	t 'has expected result'
	
	cmp	eax, result
	jne	failure
	push	rdi

	ok

	t 'has expected value'

	pop	rdi
	cmp	edi, expected
	jne	failure

	ok
}

to_number_test:
	mov	[_blue.base], 10

	tc1	not_number, 4, FAILURE, 0
	tc1	not_number2, 5, FAILURE, 1234
	tc1	zero, 1, SUCCESS, 0
	tc1	one, 1, SUCCESS, 1
	tc1	thirteen, 2, SUCCESS, 13
	tc1	thousand, 4, SUCCESS, 1000

	mov	[_blue.base], 16
	tc1	not_number, 4, FAILURE, 0
	tc1	not_number2, 5, FAILURE, 4660
	tc1	zero, 1, SUCCESS, 0
	tc1	one, 1, SUCCESS, 1
	tc1	thirteen, 2, SUCCESS, 19
	tc1	thousand, 4, SUCCESS, 4096
	tc1	FF, 2, SUCCESS, 255
	tc1	ABCDEF, 6, SUCCESS, 11259375

	ret

not_number	db '!@#$'
not_number2	db '1234p'
zero		db '0'
one		db '1'
thirteen	db '13'
thousand	db '1000'
FF		db 'FF'
ABCDEF		db 'ABCDEF'
