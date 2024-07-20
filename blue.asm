format elf64 executable 3

segment readable writeable

include "defs.inc"
include "elf_template.inc"

segment readable executable

include "linux.inc"
include "elf.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "dictionary.inc"
include "flow.inc"
include "parser.inc"
include "to_number.inc"
include "kernel.inc"
include "debug.inc"

entry $
	call	kernel_init
	
	mov	rsi, blue_bye
	mov	ecx, blue_bye.length
	xor	eax, eax

	call	kernel_loop

	cmp	eax, SUCCESS
	jne	.exit

	call	dump_code_buffer
	
	;
	; write the output to ./a.out
	;
	mov	rdi, output_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, [_code_buffer.base]
	mov	eax, [_blue.entry]
	mov	rcx, [_code_buffer.here]
	sub	rcx, rsi
	call	elf_binary_write
	
	mov	eax, SYS_CLOSE
	syscall

	call	kernel_deinit
	xor 	edi, edi

	.exit:
	mov 	eax, SYS_EXIT
	syscall

segment readable

blue_bye:
	db	'16 base '
	db	''
	db	': xor-edi (( -- )) 31 b, FF b, ; '
	db	': syscall (( ecx num -- )) B8 b, d, 0F b, 05 b, ; '
	db	''
	db	': ok (( -- )) xor-edi ; '
	db	''
	db	'0A base '
	db	''
	db	': exit (( -- )) 60 syscall ; '
	db	': bye (( -- )) ok exit ; immediate '
	db	''
	db	': _start (( -- )) bye ; entry '
	db	''
	.length = $ - blue_bye
	
output_file:
	db	"a.out"
	db	0x00
