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
	mov	[test_num], 0

	mov	esi, it##_lbl
	mov	edx, it##_lbl.length
	call	print
	
	call	it##_test

	mov	esi, ts_ok
	mov	edx, 4
	call	print
}

entry $
	mov	esi, header
	mov	edx, header.length
	call	print

	ts	code_buffer
	ts	data_stack
	ts	parser
	ts	to_number
	ts	dictionary
	ts	flow
	ts	kernel
	ts	elf

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

header:
	db 'Blue Compiler Test Suite', 10, 10
	.length = $ - header

code_buffer_lbl:
	db 'code buffer'
	.length = $ - code_buffer_lbl

data_stack_lbl:
	db 'data stack'
	.length = $ - data_stack_lbl

parser_lbl:
	db 'parser'
	.length = $ - parser_lbl

to_number_lbl:
	db 'to_number'
	.length = $ - to_number_lbl

dictionary_lbl:
	db 'dictionary'
	.length = $ - dictionary_lbl

flow_lbl:
	db 'flow'
	.length = $ - flow_lbl

kernel_lbl:
	db 'kernel'
	.length = $ - kernel_lbl

elf_lbl:
	db 'elf'
	.length = $ - elf_lbl
