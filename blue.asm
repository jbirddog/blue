format elf64 executable 3

segment readable writable executable

_BYTE = 1
_WORD = 2
_DWORD = 4
_QWORD = 8

CELL_SIZE = 8
DATA_STACK_CELLS = 64
USER_CODE_BUFFER_SIZE = 1024

; bytes to cells
macro _b2c b {
	shr	b, 3
}

; cells to bytes
macro _c2b c {
	shl	c, 3
}

; expects buffer size in edx
_read:
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
	
; expects value to push in rax
data_stack_push:
	mov	rdi, [data_stack_here]
	stosq
	mov	[data_stack_here], rdi
	ret

macro _pop1 {
	mov	rdi, [data_stack_here]
	sub	rdi, CELL_SIZE
	mov	rax, [rdi]
}

; pops value into rax
data_stack_pop:
	_pop1
	mov	[data_stack_here], rdi
	ret

; pops value into rax, second value into rdi
data_stack_pop2:
	_pop1
	sub	rdi, CELL_SIZE
	mov	[data_stack_here], rdi
	mov	rdi, [rdi]
	ret

code_buffer_dump:
	xor	eax, eax
	inc	eax
	mov	edi, eax
	mov	rsi, code_buffer
	mov	rdx, [code_buffer_here]
	sub	rdx, rsi
	syscall
	ret

exit_depth:
	call	data_stack_depth
	mov	edi, eax
	mov	eax, 60
	syscall
	
entry $
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
	call	code_buffer_dump
	call	exit_depth


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

macro _op_write l, w {
##l:
	call	data_stack_pop2
	w
	mov	rax, rdi
	call	data_stack_push
	ret
}

_op_write _06, stosb
_op_write _07, stosw
_op_write _08, stosd
_op_write _09, stosq

_0A:
	mov	rax, code_buffer
	call	data_stack_push
	ret

_0B:
	call	data_stack_pop2
	xchg	rdi, rax
	sub	rax, rdi
	call	data_stack_push
	ret

_0C:
	call	data_stack_pop2
	xchg	rdi, rax
	add	rax, rdi
	call	data_stack_push
	ret

_0D:
	call	data_stack_pop
	ret

_0E:
	call	data_stack_pop2
	push	rax
	mov	rax, rdi
	call	data_stack_push
	pop	rax
	call	data_stack_push
	ret

; TODO: make this just store l as an addr, avoid the call/ret
macro op l, b, f {
	._op##l:
	call	l
	ret
	
	assert ($ - ._op##l) <= CELL_SIZE - 2
	times (CELL_SIZE - 2 - ($ - ._op##l)) db 0
	db b, f
	assert ($ - ._op##l) = CELL_SIZE
}

ops:
	op	_00, 2, 0	; ( -- b ) read byte from input, push on the data stack
	op	_01, 3, 0	; ( -- w ) read word from input, push on the data stack
	op	_02, 5, 0	; ( -- d ) read dword from input, push on the data stack
	op	_03, 9, 0	; ( -- q ) read qword from input, push on the data stack
	op	_04, 1, 0	; ( -- a ) push addr of code buffer's here on the data stack
	op	_05, 1, 0	; ( a -- ) set addr of code buffer's here
	op	_06, 1, 0	; ( a b -- a' ) write byte to addr, push new addr on the data stack
	op	_07, 1, 0	; ( a b -- a' ) write word to addr, push new addr on the data stack
	op	_08, 1, 0	; ( a b -- a' ) write dword to addr, push new addr on the data stack
	op	_09, 1, 0	; ( a b -- a' ) write qword to addr, push new addr on the data stack
	op	_0A, 1, 0	; ( -- a ) push addr of code buffer start on the data stack
	op	_0B, 1, 0	; ( n1 n2 -- n ) n1 - n2, push result on the data stack
	op	_0C, 1, 0	; ( n1 n2 -- n ) n1 + n2, push result on the data stack
	op	_0D, 1, 0	; ( x -- ) drop top of the data stack
	op	_0E, 1, 0	; ( a b -- b a ) swap the top two items of the data stack

;
; everything below here needs to be r* else bytes will be in the binary
;

code_buffer rb USER_CODE_BUFFER_SIZE
code_buffer_here rq 1

data_stack rq DATA_STACK_CELLS
data_stack_here rq 1

tib rq 1
