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

	; TODO: exit on error
	; TODO: exit on bytes read != edx
	
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
	mov	rdi, [data_stack_here]
	stosq
	mov	[data_stack_here], rdi
	ret
	
	
entry $
	;
	; init
	;
	mov	[data_stack_here], data_stack
	
	read	_BYTE

	mov	rax, [tib]
	_c2b	rax
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


_00:
	read	_BYTE
	call	data_stack_push_tib
	ret

_01:
	read	_WORD
	call	data_stack_push_tib
	ret

_02:
	read	_DWORD
	call	data_stack_push_tib
	ret

_03:
	read	_QWORD
	call	data_stack_push_tib
	ret

macro _op l {
	._op##l:
	call	l
	ret
	
	assert ($ - ._op##l) <= CELL_SIZE
	times (CELL_SIZE - ($ - ._op##l)) db 0
	assert ($ - ._op##l) = CELL_SIZE
}

code_buffer:
	_op	_00	; ( -- b ) read byte from input, push on the data stack
	_op	_01	; ( -- w ) read word from input, push on the data stack
	_op	_02	; ( -- d ) read dword from input, push on the data stack
	_op	_03	; ( -- q ) read qword from input, push on the data stack

;
; everything below here needs to be r* else bytes will be in the binary
;

rb USER_CODE_BUFFER_SIZE

tib rq 1
data_stack_here rq 1

data_stack rq DATA_STACK_CELLS
