format elf64 executable 3

MODE_COMPILE = 0
MODE_INTERPRET = 1

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "dictionary.inc"

include "code_buffer_test.inc"
include "data_stack_test.inc"
include "dictionary_test.inc"

blue:
	.init:
	mov [_blue.mode], MODE_INTERPRET
	ret

	.deinit:
	ret

entry $
	call code_buffer_test
	call data_stack_test
	call dictionary_test

	call code_buffer.init
	call data_stack.init
	call dictionary.init

	call blue.init
	
	call code_buffer.deinit
	call data_stack.deinit
	call dictionary.deinit

	call blue.deinit
	
	xor edi, edi
	mov eax, 60
	syscall

segment readable

bootstrap:
	db '6 add1\n'
	db ': _start exit ; entry\n'
	db 0

bootstrap.length = $ - bootstrap
