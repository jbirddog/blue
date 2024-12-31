format elf64 executable 3

segment readable writable executable

_BYTE = 1
_WORD = 2
_DWORD = 4
_QWORD = 8

CELL_SIZE = 8
DATA_STACK_CELLS = 64
USER_CODE_BUFFER_SIZE = 1024

; bytes to cells, cells to bytes
macro _b2c b { shr b, 3 }
macro _c2b c { shl c, 3 }

_read:
	;
	; expects buffer size in edx
	;
	mov	[tib], 0
	
	xor	eax, eax
	xor	edi, edi
	mov	rsi, tib
	syscall
	
	ret

macro read s {
	mov	edx, s
	call	_read
}

data_stack_depth:
	mov	rax, [data_stack_here]
	sub	rax, data_stack
	_b2c	rax
	ret

data_stack_push_tib:
	mov	rax, [tib]
	
data_stack_push:
	;
	; expects value to push in rax
	;
	mov	rdi, [data_stack_here]
	stosq
	mov	[data_stack_here], rdi
	ret

data_stack_pop:
	;
	; pops value into rax
	;
	mov	rdi, [data_stack_here]
	sub	rdi, CELL_SIZE
	mov	rax, [rdi]
	mov	[data_stack_here], rdi
	ret
	
entry $
	;
	; init
	;
	mov	[code_buffer_here], code_buffer
	mov	[data_stack_here], data_stack

.read_op:
	read	_BYTE
	cmp	eax, _BYTE
	jne	.done

.call_op:
	mov	rax, [tib]
	_c2b	rax
	add	rax, ops
	call	rax
	jmp	.read_op

.done:
	call	data_stack_depth
	mov	edi, eax
	mov	eax, 60
	syscall

	; exit 7
	;db 0xbf, 0x07, 0x00, 0x00, 0x00
  	;db 0xb8, 0x3c, 0x00, 0x00, 0x00
  	;db 0x0f, 0x05


macro _op_read l, s {
##l:
	read	s
	; TODO: exit on bytes read != edx
	
	call	data_stack_push_tib
	ret
}

_op_read _00, _BYTE
_op_read _01, _WORD
_op_read _02, _DWORD
_op_read _03, _QWORD

_04:
	mov	rax, [code_buffer_here]
	call	data_stack_push
	ret

_05:
	call	data_stack_pop
	mov	[code_buffer_here], rax
	ret

_06:
	call	data_stack_pop
	push	rax
	call	data_stack_pop
	pop	rdi
	xchg	rax, rdi
	stosb
	xchg	rdi, rax
	call	data_stack_push

macro op l {
	._op##l:
	call	l
	ret
	
	assert ($ - ._op##l) <= CELL_SIZE
	times (CELL_SIZE - ($ - ._op##l)) db 0
	assert ($ - ._op##l) = CELL_SIZE
}

ops:
	op	_00	; ( -- b ) read byte from input, push on the data stack
	op	_01	; ( -- w ) read word from input, push on the data stack
	op	_02	; ( -- d ) read dword from input, push on the data stack
	op	_03	; ( -- q ) read qword from input, push on the data stack
	op	_04	; ( -- a ) push addr of code buffer's here on the data stack
	op	_05	; ( a -- ) set addr of code buffer's here
	op	_06	; ( a b -- a' ) write byte to addr, push new addr on the data stack

;
; everything below here needs to be r* else bytes will be in the binary
;

code_buffer rb USER_CODE_BUFFER_SIZE
code_buffer_here rq 1

data_stack rq DATA_STACK_CELLS
data_stack_here rq 1

tib rq 1
