
macro tc1 tib, tib_len, expected, expected_len {
	call	kernel_init

	mov	rsi, tib
	mov	ecx, tib_len
	xor	eax, eax

	call	kernel_loop

	t 'parsed blue successfully'
	
	cmp	eax, SUCCESS
	jne	failure

	ok

	t 'has the exepected compilation'
	
	mov	rsi, expected
	mov	ecx, expected_len
	call	check_code_buffer

	ok
	
	call	kernel_deinit
}

macro tc2 tib, tib_len {
	call	kernel_init

	mov	rsi, tib
	mov	ecx, tib_len
	xor	eax, eax

	call	kernel_loop

	t 'failed to parse as expected'
	
	cmp	eax, FAILURE
	jne	failure
	push	rdi

	ok

	t 'returned the correct error'

	pop	rdi
	cmp	edi, ERR_NOT_A_WORD
	jne	failure

	ok
	
	call	kernel_deinit
}

kernel_test:
	call kernel_init

	t 'inits base correctly'
	
	cmp	[_blue.base], 10
	jne	failure

	ok

	t 'inits mode correctly'
	
	cmp	[_blue.mode], INTERPRET
	jne	failure

	ok
	
	call	kernel_deinit

	tc1	one_byte.blue, one_byte.blue_length, \
		one_byte.expected, one_byte.expected_length 

	tc1	clean_exit.blue, clean_exit.blue_length, \
		clean_exit.expected, clean_exit.expected_length 

	tc2	bogus.blue, bogus.blue_length
		
	ret

bogus:
	.blue:
	db	'^%^*^%'
	.blue_length = $ - .blue

one_byte:
	.blue:
	db	'1 b,'
	.blue_length = $ - .blue

	.expected:
	db	0x01
	.expected_length = $ - .expected
	
clean_exit:
	.blue:
	db	'49 b, 255 b, '		; xor edi, edi
	db	'184 b, 60 d, '		; mov eax, 60
	db	'15 b, 5 b,'		; syscall
	.blue_length = $ - .blue

	.expected:
	db	0x31, 0xff
	db	0xb8
	dd	0x3c
	db	0x0f, 0x05
	.expected_length = $ - .expected
