format elf64 executable 3

macro tc1 tib, tib_len, expected, expected_len {
	mov	rsi, tib
	mov	ecx, tib_len
	xor	eax, eax

	call	kernel_init
	call	kernel_deinit
	
	;inc	[test_num]
	;cmp	rax, expected
	;jne	failure
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "dictionary.inc"
include "parser.inc"
include "to_number.inc"
include "kernel.inc"

entry $
	mov	[test_num], 0

	call kernel_init
	
	inc	[test_num]
	cmp	[_blue.base], 10
	jne	failure
	
	inc	[test_num]
	cmp	[_blue.mode], INTERPRET
	jne	failure
	
	call	kernel_deinit

	tc1	clean_exit.blue, clean_exit.blue_length, \
		clean_exit.expected, clean_exit.expected_length 

	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

segment readable

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
