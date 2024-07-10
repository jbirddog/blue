
macro tc1 what {
	call	kernel_init

	mov	rsi, what##.blue
	mov	ecx, what##.blue_length
	xor	eax, eax

	call	kernel_loop

	t 'parsed blue successfully'
	
	cmp	eax, SUCCESS
	jne	failure

	ok

	t 'has the expected mode'
	
	cmp	[_blue.mode], INTERPRET
	jne	failure

	ok

	t 'has the expected compilation'
	
	mov	rsi, what##.expected
	mov	rcx, what##.expected_length
	call	check_code_buffer

	ok
	
	call	kernel_deinit
}

macro tc2 what {
	call	kernel_init

	mov	rsi, what##.blue
	mov	ecx, what##.blue_length
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

macro tc3 what {
	call	kernel_init

	mov	rsi, what##.blue
	mov	ecx, what##.blue_length
	xor	eax, eax

	call	kernel_loop

	t 'parsed blue successfully'
	
	cmp	eax, SUCCESS
	jne	failure

	ok

	t 'has the expected mode'
	
	cmp	[_blue.mode], INTERPRET
	jne	failure

	ok

	t 'has the expected entry'
	
	mov	ecx, [what##.expected]
	mov	eax, [_blue.entry]
	cmp	eax, ecx
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

	t 'inits entry correctly'
	
	cmp	[_blue.entry], 0
	jne	failure

	ok
	
	call	kernel_deinit

	;tc1	one_byte
	;tc1	two_bytes
	;tc1	one_byte_base16
	;tc1	clean_exit
	;tc1	user_one_byte
	;tc1	user_empty_words
	;tc1	seX_empty
	;tc1	ise_1
	tc1	ise_2
	
	;tc2	bogus

	;tc3	entry_0
	;tc3	entry_18
	
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

two_bytes:
	.blue:
	db	'1 b, 2 b,'
	.blue_length = $ - .blue

	.expected:
	db	0x01, 0x02
	.expected_length = $ - .expected

one_byte_base16:
	.blue:
	db	'16 base FF b,'
	.blue_length = $ - .blue

	.expected:
	db	0xFF
	.expected_length = $ - .expected
	
clean_exit:
	.blue:
	db	'16 base '
	db	'31 b, FF b, '		; xor edi, edi
	db	'B8 b, 3C d, '		; mov eax, 60
	db	'0F b, 05 b,'		; syscall
	.blue_length = $ - .blue

	.expected:
	db	0x31, 0xff
	db	0xb8
	dd	0x3c
	db	0x0f, 0x05
	.expected_length = $ - .expected

user_one_byte:
	.blue:
	db	': 1b 1 b, ; '
	db	'1b'
	.blue_length = $ - .blue

	.expected:
	db	0x01
	.expected_length = $ - .expected

seX_empty:
	.blue:
	db	': 1b (( -- )) 1 b, ; '
	db	'1b'
	.blue_length = $ - .blue

	.expected:
	db	0x01
	.expected_length = $ - .expected

ise_1:
	.blue:
	db	': syscall (( num eax -- )) ; '
	db	': _ 60 syscall ; entry '
	.blue_length = $ - .blue

	.expected:
	db	0xc3
	db	0xb8
	dd	0x3c
	db	0xe8
	db	0xf5, 0xff, 0xff, 0xff
	db	0xc3
	.expected_length = $ - .expected

ise_2:
	.blue:
	db	': syscall (( num eax -- )) d, ; immediate '
	db	': _ 7 syscall ; entry '
	.blue_length = $ - .blue

	.expected:
	db	0xc3
	dd	0x07
	db	0xc3
	.expected_length = $ - .expected

entry_0:
	.blue:
	db	': 1b 1 b, ; entry '
	.blue_length = $ - .blue

	.expected:
	dd	0x00

entry_18:
	.blue:
	db	': 1b 1 b, ; '
	db	': _start 1b ; entry '
	.blue_length = $ - .blue

	.expected:
	dd	0x12
	
user_empty_words:
	.blue:
	db	'16 base '
	db	'90 b, 90 b, 90 b, '
	db	': x ; '
	db	': y ; '
	db	': z ; '
	db	'x y z '
	.blue_length = $ - .blue

	.expected:
	db	0x90, 0x90, 0x90
	db	0xc3, 0xc3, 0xc3
	.expected_length = $ - .expected
	
