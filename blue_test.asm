format elf64 executable 3

segment readable writeable

include "defs.inc"
include "elf_template.inc"

test_id db 1
test_num db 1

fstat_buffer:
	rb	48
	.file_size:
	rq	1
	rb	88

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "parser.inc"
include "to_number.inc"
include "dictionary.inc"
include	"flow.inc"
include "kernel.inc"
include "elf.inc"

macro t what {
	inc	[test_num]
}

macro ok {
	mov	esi, dot
	call	print_char
}

include "code_buffer_test.inc"
include "data_stack_test.inc"
include "parser_test.inc"
include "to_number_test.inc"
include "dictionary_test.inc"
include "flow_test.inc"
include "kernel_test.inc"
include "elf_test.inc"

macro ts it {
	inc	[test_id]
	mov	[test_num], 0

	mov	esi, test_id
	call	print_char
	
	call	it

	mov	esi, ts_ok
	mov	edx, 4
	call	print
}

entry $
	mov	[test_id], 32

	ts	code_buffer_test
	ts	data_stack_test
	ts	parser_test
	ts	to_number_test
	ts	dictionary_test
	ts	flow_test
	ts	kernel_test
	ts	elf_test

	mov	esi, newline
	call	print_char

	call	execve_hello_world

failure:
	mov	esi, X
	call	print_char

	mov	esi, newline
	call	print_char
	
	mov	dil, [test_num]
	mov	eax, 60
	syscall

print_char:
	mov	edx, 1

print:
	mov	edi, STDOUT_FILENO
	mov	eax, SYS_WRITE
	syscall
	ret

newline db 10
dot db '.'
X db 'X'
ts_ok db ' ok', 10
