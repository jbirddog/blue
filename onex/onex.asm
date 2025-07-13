
format ELF64 executable 3

segment readable writeable executable

name:	dd "onex"
ver:	dd 0

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
DICT_SIZE = DICT_ENTRY_SIZE * 64
DST_SIZE = 1024
SRC_SIZE = 1024

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12
REG_DS = r13

;
; data stack
;

DS_SIZE = CELL_SIZE * 16
DS_MASK = DS_SIZE - 1
DS_BASE = $ - DS_SIZE

assert DS_SIZE and DS_MASK = 0
assert DS_BASE and DS_MASK = 0

ds_push:
	mov	[REG_DS], rax
	add	REG_DS, CELL_SIZE
	and	REG_DS, DS_MASK
	or	REG_DS, DS_BASE

	ret

ds_pop:
	sub	REG_DS, CELL_SIZE
	and	REG_DS, DS_MASK
	or	REG_DS, DS_BASE
	mov	rax, [REG_DS]

	ret

;
; kernel
;

dollar_dollar	dq _dst

dollar:
	mov	rax, REG_DST
	jmp	ds_push

dup:
	call	ds_pop
	call	ds_push
	jmp	ds_push

plus:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	add	rax, rcx
	jmp	ds_push

minus:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	sub	rax, rcx
	jmp	ds_push

b_comma:
	call	ds_pop
	stosb

	ret

w_comma:
	call	ds_pop
	stosw

	ret

set:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	[rbx], rax
	
	ret

exec_num:
	lodsq
	jmp	ds_push

comp_num:
	movsq
	
ed_nop:
	ret

def_word:
	lodsq
	
	add	REG_LAST, DICT_ENTRY_SIZE
	mov	[REG_LAST], rax
	mov	[REG_LAST + CELL_SIZE], rdi
	
	ret

xt:
	lodsq
	push	REG_LAST
.find:
	mov	rbx, [REG_LAST]
	cmp	rax, rbx
	je	.done

	test	rbx, rbx
	jz	.done
	
	sub	REG_LAST, DICT_ENTRY_SIZE
	jmp	.find

.done:
	mov	rax, [REG_LAST + CELL_SIZE]
	pop	REG_LAST
	
	ret

exec_word:
	call	xt
	call	rax
	
	ret

ref_word:
	call	xt
	jmp	ds_push

fin:
	mov	rdx, REG_DST
	mov	rsi, [dollar_dollar]
	
	xor	edi, edi
	inc	edi
	sub	rdx, rsi
	mov	eax, edi
	syscall
	
	xor	edi, edi
	mov	eax, 60
	syscall

;
; bytecode table
;

bc_tbl:
dq	fin
dq	def_word
dq	exec_word
dq	ref_word
dq	comp_num
dq	exec_num
dq	ed_nop

;
; main
;

entry $
	xor	edi, edi
	mov	rsi, _src
	mov	edx, SRC_SIZE
	xor	eax, eax
	syscall

	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_DS, DS_BASE
	mov	REG_LAST, _dict.last

;
; interpreter
;

interpret:
	xor	eax, eax
	lodsb
	
	call	qword [bc_tbl + (rax * CELL_SIZE)]
	jmp	interpret

;
; dictionary
;

_dict:
dq	"!", set
dq	"b,", b_comma
dq	"w,", w_comma
dq	"+", plus
dq	"-", minus
dq	"dup", dup
dq	"$$", dollar_dollar
.last:
dq	"$", dollar

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
