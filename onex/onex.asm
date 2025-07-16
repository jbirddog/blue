
format ELF64 executable 3

segment readable writeable executable

magic:
.name:	dd "onex"
.ver:	dd 0

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 3
DICT_SIZE = DICT_ENTRY_SIZE * 128
DST_SIZE = 4096
SRC_SIZE = 4096

DS_SIZE = CELL_SIZE * 16
DS_MASK = DS_SIZE - 1
DS_BASE = $ - DS_SIZE

assert DS_SIZE and DS_MASK = 0
assert DS_BASE and DS_MASK = 0

REG_IND = ebp
REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12
REG_DS = r13

;
; kernel
;

k_org		dq DS_BASE
dollar_dollar	dq _dst

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

find:
	lodsq
	push	REG_LAST
.loop:
	mov	rbx, [REG_LAST]
	cmp	rax, rbx
	je	.done

	test	rbx, rbx
	jz	.done
	
	sub	REG_LAST, DICT_ENTRY_SIZE
	jmp	.loop

.done:
	mov	rax, REG_LAST
	pop	REG_LAST
	ret

;
; core words
;
	
dup:
	call	ds_pop
	call	ds_push
	jmp	ds_push

b_comma:
	call	ds_pop
	stosb
	ret

w_comma:
	call	ds_pop
	stosw
	ret

d_comma:
	call	ds_pop
	stosd
	ret

comma:
	call	ds_pop
	stosq
	ret

fetch:
	call	ds_pop
	mov	rax, [rax]
	jmp	ds_push

set:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	[rbx], rax
	ret

xt:
	call	find
	mov	rax, [rax + CELL_SIZE]
	ret

;
; bytecode handlers
;

fin:
	mov	rdx, REG_DST
	mov	rsi, [dollar_dollar]
	
	xor	edi, edi
	inc	edi
	sub	rdx, rsi
	mov	eax, edi
	syscall
	
	xor	edi, edi
	mov	al, 60
	syscall

word_define:
	lodsq
	add	REG_LAST, DICT_ENTRY_SIZE
	mov	[REG_LAST], rax
	mov	[REG_LAST + CELL_SIZE], rdi
	mov	[REG_LAST + (CELL_SIZE * 2)], rsi
	jmp	next

word_end:
	test	REG_IND, REG_IND
	jz	.top_level

	dec	REG_IND
	pop	REG_SRC
	jmp	.done

.top_level:
.done:
	jmp	next
	
word_exec:
	call	xt
	call	rax
	jmp	next

word_interp:
	call	find
	push	REG_SRC
	inc	REG_IND
	mov	REG_SRC, [rax + (CELL_SIZE * 2)]
	jmp	next

word_caddr:
	call	xt
	call	ds_push
	jmp	next

word_raddr:
	call	xt
	sub	rax, [dollar_dollar]
	add	rax, [k_org]
	call	ds_push
	jmp	next

num_comp:
	movsq
	jmp	next

num_exec:
	lodsq
	call	ds_push
	jmp	next

k_add:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	add	rax, rcx
	call	ds_push
	jmp	next

k_sub:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	sub	rax, rcx
	call	ds_push
	jmp	next

k_or:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	or	rax, rcx
	call	ds_push
	jmp	next

k_shl:
	call	ds_pop
	mov	cl, al
	call	ds_pop
	shl	rax, cl
	call	ds_push
	jmp	next

ed_nl:
	jmp	next

cdollar:
	mov	rax, REG_DST
	call	ds_push
	jmp	next
	
;
; interpreter
;
	
next:
	xor	eax, eax
	lodsb
	jmp	qword [bc_tbl + (rax * CELL_SIZE)]

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

	jmp	next

;
; bytecode handler table
;

bc_tbl:
dq	fin
dq	word_define
dq	word_end
dq	word_exec
dq	word_interp
dq	word_caddr
dq	word_raddr
dq	num_comp
dq	num_exec
dq	k_add
dq	k_sub
dq	k_or
dq	k_shl
dq	ed_nl

dq	cdollar

;
; dictionary
;

_dict:
dq	"!", set, 0
dq	"@", fetch, 0
dq	"b,", b_comma, 0
dq	"w,", w_comma, 0
dq	"d,", d_comma, 0
dq	",", comma, 0
dq	"dup", dup, 0
dq	"org", k_org, 0
.last:
dq	"$$", dollar_dollar, 0

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
