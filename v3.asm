format elf64 executable 3

segment readable writable executable


DATA_STACK_ELEMS = 64
USER_CODE_BUFFER_SIZE = 1024
WORD_SIZE = 16
WORD_SIZE_SHL = 4

read_input:
	;
	; expects buffer size in edx
	;
	mov	[tib], 0
	
	xor	eax, eax
	xor	edi, edi
	mov	rsi, tib
	syscall

	; TODO: exit on error
	; TODO: exit on bytes read != edx
	
	ret

read_input_b:
	mov	edx, 1
	jmp	read_input

push_tib:
	mov	rax, [tib]
	mov	rdi, [data_stack_here]
	stosq
	mov	[data_stack_here], rdi
	ret

data_stack_depth:
	mov	rax, [data_stack_here]
	sub	rax, data_stack
	shr	rax, 3
	ret
	
	
entry $
	;
	; init
	;
	mov	[data_stack_here], data_stack
	
	call	read_input_b

	mov	rax, [tib]
	shl	rax, WORD_SIZE_SHL
	add	rax, code_buffer
	call	rax

	call	data_stack_depth

	mov	edi, eax
	mov	eax, 60
	syscall

	; exit 7
	;db 0xbf, 0x07, 0x00, 0x00, 0x00
  	;db 0xb8, 0x3c, 0x00, 0x00, 0x00
  	;db 0x0f, 0x05

; TODO: macro op that takes body
macro _pad op {
	assert ($ - op) <= WORD_SIZE
	times (WORD_SIZE - ($ - op)) db 0
	assert ($ - op) = WORD_SIZE
}
	
code_buffer:
_op_00:
	; ( -- b ) - read byte from input, push on the data stack
	call	read_input_b
	call	push_tib
	ret

	_pad _op_00

;
; everything below here needs to be r* else bytes will be in the binary
;

rb USER_CODE_BUFFER_SIZE

tib rq 1
data_stack_here rq 1

data_stack rq DATA_STACK_ELEMS
