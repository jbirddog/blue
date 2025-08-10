
format ELF64 executable 3

segment readable writeable executable

magic:
.name:	dd "blue"
.ver:	dd 5

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 3
DICT_SIZE = DICT_ENTRY_SIZE * 256
DST_SIZE = 8192
SRC_SIZE = 8192

DS_SIZE = CELL_SIZE * 16
DS_MASK = DS_SIZE - 1
DS_BASE = $ - DS_SIZE

K_ORG = DS_BASE

assert DS_SIZE and DS_MASK = 0
assert DS_BASE and DS_MASK = 0

REG_LVL equ ebp
REG_SRC equ rsi
REG_DST equ rdi
REG_DSTB equ r11
REG_LAST equ r12
REG_DS equ r13

;;; kernel

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

ds_pop2:
	call	ds_pop
	mov	rcx, rax
	jmp	ds_pop

find:
	push	REG_LAST
	lodsq

.check:
	cmp	rax, [REG_LAST]
	je	.found
	
	sub	REG_LAST, DICT_ENTRY_SIZE
	jmp	.check

.found:
	mov	rax, REG_LAST
	pop	REG_LAST
	ret

xt:
	call	find
	mov	rax, [rax + CELL_SIZE]
	ret

;;; opcode handlers

fin:
	mov	rdx, REG_DST
	mov	rsi, REG_DSTB
	
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
	mov	[REG_LAST + CELL_SIZE], REG_DST
	mov	[REG_LAST + (CELL_SIZE * 2)], REG_SRC
	jmp	next

word_end:
	test	REG_LVL, REG_LVL
	jz	.top_level

	dec	REG_LVL
	pop	REG_SRC
	jmp	.done

.top_level:
	cmp	byte [REG_DST - 5], 0xE8
	jne	.cret
	inc	byte [REG_DST - 5]
	jmp	.done

.cret:
	mov	al, 0xC3
	stosb

.done:
	jmp	next

word_ccall:
	call	xt
	call	rax
	jmp	next

word_rcall:
	mov	al, 0xE8
	stosb
	call	xt
	sub	rax, REG_DST
	sub	rax, 4
	stosd
	jmp	next

word_interp:
	call	find
	push	REG_SRC
	inc	REG_LVL
	mov	REG_SRC, [rax + (CELL_SIZE * 2)]
	jmp	next

word_caddr:
	call	xt
	call	ds_push
	jmp	next

word_raddr:
	call	xt
raddr:
	sub	rax, REG_DSTB
	add	rax, K_ORG
	call	ds_push
	jmp	next

num_comp:
	movsq
	jmp	next

num_push:
	lodsq
	call	ds_push
	jmp	next
	
k_dup:
	call	ds_pop
	call	ds_push
	call	ds_push
	jmp	next

k_add:
	call	ds_pop2
	add	rax, rcx
	call	ds_push
	jmp	next

k_sub:
	call	ds_pop2
	sub	rax, rcx
	call	ds_push
	jmp	next

k_or:
	call	ds_pop2
	or	rax, rcx
	call	ds_push
	jmp	next

k_shl:
	call	ds_pop2
	shl	rax, cl
	call	ds_push
	jmp	next

dsp_nl:
	jmp	next

dollar_caddr:
	mov	rax, REG_DST
	call	ds_push
	jmp	next

dollar_raddr:
	mov	rax, REG_DST
	jmp	raddr

dst_base:
	mov	rax, REG_DSTB
	call	ds_push
	jmp	next

dst_base_set:
	call	ds_pop
	mov	REG_DSTB, rax
	jmp	next

k_set:
	call	ds_pop
	mov	rcx, rax
	call	ds_pop
	mov	[rcx], rax
	jmp	next

k_fetch:
	call	ds_pop
	mov	rax, [rax]
	call	ds_push
	jmp	next

comma_b:
	call	ds_pop
	stosb
	jmp	next

comma_w:
	call	ds_pop
	stosw
	jmp	next

comma_d:
	call	ds_pop
	stosd
	jmp	next

comma:
	call	ds_pop
	stosq
	jmp	next

;;; interpreter
	
next:
	xor	eax, eax
	lodsb
	jmp	qword [bc_tbl + (rax * CELL_SIZE)]

;;; main

entry $
	xor	edi, edi
	mov	rsi, _src
	mov	edx, SRC_SIZE
	xor	eax, eax
	syscall

	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_DS, DS_BASE
	mov	REG_LAST, _dict - DICT_ENTRY_SIZE

	jmp	next

;;; opcode table

bc_tbl:
dq	fin
dq	word_define, word_end, word_ccall, word_rcall, word_interp, word_caddr, word_raddr
dq	num_comp, num_push
dq	k_dup, k_add, k_sub, k_or, k_shl
dq	dollar_caddr, dollar_raddr, dst_base, dst_base_set
dq	k_set, k_fetch, comma_b, comma_w, comma_d, comma
dq	dsp_nl

;;; reserved

_dict rb DICT_SIZE
_dst rb DST_SIZE
_src rb SRC_SIZE
