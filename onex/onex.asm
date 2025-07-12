
format ELF64 executable 3

segment readable writeable executable

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
DICT_SIZE = DICT_ENTRY_SIZE * 64
DST_SIZE = 1024
SRC_SIZE = 1024

SYS_EXIT = 60

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12
REG_DS = r13

;
; data stack
;

DS_SIZE = CELL_SIZE * 16
DS_MASK = DS_SIZE - 1

assert DS_SIZE and DS_MASK = 0

align DS_SIZE

DS_BASE = $ - DS_SIZE

assert DS_BASE and DS_MASK = 0

macro chk_ds_wrap i, w
	assert (((DS_BASE + (i shl 3)) and DS_MASK) or DS_BASE) = DS_BASE + (w shl 3)
end macro

chk_ds_wrap	0, 0
chk_ds_wrap	4, 4
chk_ds_wrap	15, 15
chk_ds_wrap	16, 0
chk_ds_wrap	17, 1
chk_ds_wrap	-1, 15
chk_ds_wrap	-4, 12

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
; interpreter
;

interpret:
.loop:
	xor	eax, eax
	lodsb

	test	al, al
	jz	.done
	
	call	qword [bc_tbl + (rax * CELL_SIZE)]
	jmp	.loop

.done:
	ret

;
; main
;

entry $

	; read at most a SRC_SIZE of bytecode from stdin
	xor	edi, edi
	mov	rsi, _src
	mov	edx, SRC_SIZE
	xor	eax, eax
	syscall

	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_DS, DS_BASE
	mov	REG_LAST, _dict.last

	push	REG_DST

	call	interpret

	; write assembled code
	mov	rdx, REG_DST
	pop	rsi
	
	xor	edi, edi
	inc	edi
	sub	rdx, rsi
	mov	eax, edi
	syscall
	
	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall


k_define:
	lodsq
	
	add	REG_LAST, DICT_ENTRY_SIZE
	mov	[REG_LAST], rax
	mov	[REG_LAST + CELL_SIZE], rdi
	
	ret

k_xt:
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

k_dstsz:
	mov	rax, REG_DST
	sub	rax, _dst
	jmp	ds_push

k_exec_word:
	call	k_xt
	call	rax
	ret

k_exec_num:
	lodsq
	jmp	ds_push

k_comp_num:
	movsq
	ret

k_nop:
	ret

k_ref_word:
	call	k_xt
	jmp	ds_push

b_comma:
	call	ds_pop
	stosb

	ret

w_comma:
	call	ds_pop
	stosw

	ret
	
k_setq:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	[rbx], rax
	
	ret

bc_tbl:
dq	0x00
dq	k_define
dq	k_exec_word
dq	k_ref_word
dq	k_comp_num
dq	k_exec_num
dq	k_nop

_dict:
dq	"!", k_setq
dq	"b,", b_comma
dq	"w,", w_comma
.last:
dq	"dstsz", k_dstsz

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
