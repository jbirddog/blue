
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

d_comma:
	call	ds_pop
	stosd
	ret

comma:
	call	ds_pop
	stosq
	ret

b_fetch:
	call	ds_pop
	mov	rbx, rax
	xor	eax, eax
	mov	al, byte [rbx]
	jmp	ds_push

w_fetch:
	call	ds_pop
	mov	rbx, rax
	xor	eax, eax
	mov	ax, word [rbx]
	jmp	ds_push

d_fetch:
	call	ds_pop
	mov	rbx, rax
	mov	eax, dword [rbx]
	jmp	ds_push

fetch:
	call	ds_pop
	mov	rax, [rax]
	jmp	ds_push

b_set:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	byte [rbx], al
	ret

w_set:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	word [rbx], ax
	ret

d_set:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	dword [rbx], eax
	ret

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
	mov	eax, 60
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

ed_nl:
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
dq	ed_nl

;
; dictionary
;

_dict:
dq	"org", k_org, 0
dq	"$$", dollar_dollar, 0
dq	"$", dollar, 0
dq	"b!", b_set, 0
dq	"w!", w_set, 0
dq	"d!", d_set, 0
dq	"!", set, 0
dq	"b@", fetch, 0
dq	"w@", fetch, 0
dq	"d@", fetch, 0
dq	"@", fetch, 0
dq	"b,", b_comma, 0
dq	"w,", w_comma, 0
dq	"d,", d_comma, 0
dq	",", comma, 0
dq	"+", plus, 0
dq	"-", minus, 0
.last:
dq	"dup", dup, 0

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
