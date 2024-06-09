format elf64 executable 3
	
segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "dictionary.inc"

include "data_stack_test.inc"

entry $
	call data_stack_test

	call code_buffer.init
	call data_stack.init
	call dictionary.init
	
	call code_buffer.deinit
	call data_stack.deinit
	call dictionary.deinit
	
	xor edi, edi
	mov eax, 60
	syscall
