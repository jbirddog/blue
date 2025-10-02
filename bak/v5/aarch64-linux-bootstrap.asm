
processor cpu64_v8
code64

format ELF64 executable

segment readable writeable executable

magic:
.name:	dw "blue"
.ver:	dw 5

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

REG_LVL equ w10
REG_SRC equ x11
REG_DST equ x12
REG_DSTB equ x13
REG_LAST equ x14
REG_DS equ x15

BL_MASK dw 0x97 shl 24
B_OFFSET_MASK dw not (0xFF shl 24)

;;; kernel

ds_push:
	str	x9, [REG_DS], 8
	and	REG_DS, REG_DS, DS_MASK
	orr	REG_DS, REG_DS, DS_BASE
_ret:
	ret

ds_push2:
_pre_rcall:
	str	x30, [sp, -16]!
	bl	ds_push
_post_rcall:
	ldr	x30, [sp], 16
	mov	x9, x8
	b	ds_push

ds_pop:
	sub	REG_DS, REG_DS, CELL_SIZE
	and	REG_DS, REG_DS, DS_MASK
	orr	REG_DS, REG_DS, DS_BASE
	ldr	x9, [REG_DS]
	ret

ds_pop2:
	mov	x0, x30
	bl	ds_pop
	mov	x8, x9
	mov	x30, x0
	b	ds_pop

find:
	str	REG_LAST, [sp, -16]!
	ldr	x9, [REG_SRC], 8

.check:
	ldr	x8, [REG_LAST]
	cmp	x9, x8
	b.ne	.prev
	
	mov	x9, REG_LAST
	ldr	REG_LAST, [sp], 16
	ret

.prev:
	sub	REG_LAST, REG_LAST, DICT_ENTRY_SIZE
	b	.check

xt:
	mov	x0, x30
	bl	find
	mov	x30, x0
	ldr	x8, [x9, CELL_SIZE]
	mov	x9, x8
	ret

;;; opcode handlers

fin:
	mov	x0, 1
	mov	x1, REG_DSTB
	sub	x2, REG_DST, REG_DSTB
	mov	w8, 64
	svc	0

	mov	x0, 11
	mov	w8, 93
	svc	0

word_define:
	ldr	x9, [REG_SRC], 8
	; TODO: think these two can be combined into a !
	add	REG_LAST, REG_LAST, DICT_ENTRY_SIZE
	str	x9, [REG_LAST]
	str	REG_DST, [REG_LAST, CELL_SIZE]
	str	REG_SRC, [REG_LAST, (CELL_SIZE * 2)]	
	b	next

word_end:
	cmp	REG_LVL, 0
	b.eq	.top_level

	sub	REG_LVL, REG_LVL, 1
	ldr	REG_SRC, [sp], 16
	b	.done

.top_level:
	; TODO: cmp REG_DST - 4 and BL_MASK == BL_MASK
	; TODO: b.ne
	b	.cret
	; TODO: flip bit 31 (i think is all) of REG_DST - 4
	; TODO: REG_DST - 8 is nop (clear _pre_rcall)
	; TODO: sub 4 from REG_DST to drop _post_rcall
	b	.done

.cret:
	ldr	w9, _ret
	str	w9, [REG_DST], 4

.done:
	b	next

word_ccall:
	bl	xt
	br	x9
	b	next

word_rcall:
	ldr	w9, _pre_rcall
	str	w9, [REG_DST], 4
	
	bl	xt
	;(0x97 shl 24) or (((xt - dst) shr 2) and (not (0xFF shl 24))) 
	sub	x9, x9, REG_DST
	lsr	x9, x9, 2
	ldr	w8, B_OFFSET_MASK
	and	w9, w9, w8
	ldr	w8, BL_MASK
	orr	w9, w9, w8
	str	w9, [REG_DST], 4
	
	ldr	w9, _post_rcall
	str	w9, [REG_DST], 4
	b	next

word_interp:
	bl	find
	str	REG_SRC, [sp, -16]!
	add	REG_LVL, REG_LVL, 1
	ldr	REG_SRC, [x9, (CELL_SIZE * 2)]
	b	next

word_caddr:
	bl	xt
	bl	ds_push
	b	next

word_raddr:
	bl	xt
raddr:
	sub	x9, x9, REG_DSTB
	add	x9, x9, K_ORG
	bl	ds_push
	b	next

num_comp:
	ldr	x9, [REG_SRC], 8
	str	x9, [REG_DST], 8
	b	next
	
num_push:
	ldr	x9, [REG_SRC], 8
	bl	ds_push
	b	next

tor:
	bl	ds_pop
	str	x9, [sp, -16]!
	b	next

fromr:
	ldr	x9, [sp], 16
	bl	ds_push
	b	next

swap:
	bl	ds_pop2
	mov	x7, x9
	mov	x9, x8
	mov	x8, x7
	bl	ds_push2
	b	next

k_dup:
	bl	ds_pop
	bl	ds_push
	bl	ds_push
	b	next

k_add:
	bl	ds_pop2
	add	x9, x9, x8
	bl	ds_push
	b	next

k_sub:
	bl	ds_pop2
	sub	x9, x9, x8
	bl	ds_push
	b	next

k_or:
	bl	ds_pop2
	orr	x9, x9, x8
	bl	ds_push
	b	next

k_shl:
	bl	ds_pop2
	lsl	x9, x9, x8
	bl	ds_push
	b	next

dollar_caddr:
	mov	x9, REG_DST
	bl	ds_push
	b	next

dollar_raddr:
	mov	x9, REG_DST
	b	raddr

dst_base:
	mov	x9, REG_DSTB
	bl	ds_push
	b	next

dst_base_set:
	bl	ds_pop
	mov	REG_DSTB, x9
	b	next

set_b:
	bl	ds_pop2
	strb	w9, [x8]
	b	next

set:
	bl	ds_pop2
	str	x9, [x8]
	b	next

fetch:
	bl	ds_pop
	ldr	x9, [x9]
	bl	ds_push
	b	next

comma_b:
	bl	ds_pop
	strb	w9, [REG_DST], 1
	b	next

comma_w:
	bl	ds_pop
	strh	w9, [REG_DST], 2
	b	next

comma_d:
	bl	ds_pop
	str	w9, [REG_DST], 4
	b	next

comma:
	bl	ds_pop
	str	x9, [REG_DST], 8
	b	next

dsp_nl:
	b	next

;;; interpreter

next:
	ldrb	w9, [REG_SRC], 1
	lsl	w9, w9, 3
	adr	x8, bc_tbl
	add	x8, x8, x9
	ldr	x9, [x8]
	br	x9

;;; main

entry $
	mov	x0, 0
	adr	x1, _src
	mov	x2, SRC_SIZE
	mov	w8, 63
	svc	0

	adr	REG_SRC, _src
	adr	REG_DSTB, _dst
	adr	REG_DST, _dst
	mov	REG_DS, DS_BASE
	adr	REG_LAST, _dict
	sub	REG_LAST, REG_LAST, DICT_ENTRY_SIZE
	
	b	next

;;; opcode table

bc_tbl:
dd	fin
dd	word_define, word_end, word_ccall, word_rcall, word_interp, word_caddr, word_raddr
dd	num_comp, num_push
dd	tor, fromr, swap, k_dup, k_add, k_sub, k_or, k_shl
dd	dollar_caddr, dollar_raddr, dst_base, dst_base_set
dd	set_b, set, fetch, comma_b, comma_w, comma_d, comma
dd	dsp_nl

;;; reserved

_dict rb DICT_SIZE
_dst rb DST_SIZE
_src rb SRC_SIZE
