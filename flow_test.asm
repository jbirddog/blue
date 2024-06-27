format elf64 executable 3

macro tc1 tib, tib_len, expected, expected_len {
	call	kernel_init

	mov	rsi, tib
	mov	ecx, tib_len
	xor	eax, eax

	call	kernel_loop

	inc	[test_num]
	cmp	eax, SUCCESS
	jne	failure
	
	mov	rsi, expected
	mov	ecx, expected_len
	call	check_code_buffer
	
	call	kernel_deinit
}

macro tc2 tib, tib_len {
	call	kernel_init

	mov	rsi, tib
	mov	ecx, tib_len
	xor	eax, eax

	call	kernel_loop

	inc	[test_num]
	cmp	eax, FAILURE
	jne	failure

	cmp	edi, ERR_NOT_A_WORD
	jne	failure
	
	call	kernel_deinit
}

segment readable writeable

include "defs.inc"

test_num db 1

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "data_stack.inc"
include "dictionary.inc"
include	"flow.inc"

entry $
	mov	[test_num], 0

	call	code_buffer_init
	call	data_stack_init

	mov	eax, 0x3c
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	
	mov	rax, _core_words.b_comma
	call	flow_in

	inc	[test_num]
	mov	rsi, flow_1
	mov	ecx, flow_1.length
	call	check_code_buffer
	
	call	code_buffer_deinit
	call	data_stack_deinit
	
	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall

failure:
	mov	dil, [test_num]
	jmp	exit

check_code_buffer:
	mov	rdi, [_code_buffer.here]
	sub	rdi, [_code_buffer.base]

	cmp	edi, ecx
	jne	failure
	
	mov	rdi, [_code_buffer.base]
	
	.loop:
	cmpsb
	jne	failure

	dec	ecx
	jnz	.loop
	
	ret

segment readable

flow_1:
	db	0xb8
	dd	0x3c
	.length = $ - flow_1
