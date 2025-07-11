
format ELF64 executable 3

segment readable writeable executable

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
DICT_SIZE = DICT_ENTRY_SIZE * 64
DS_SIZE = CELL_SIZE * 16
DST_SIZE = 1024
SRC_SIZE = 1024

assert DS_SIZE and (DS_SIZE - 1) = 0

SYS_EXIT = 60

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12
REG_DS = r13

;
;
;

_pre_ds_align:
align DS_SIZE
assert $ - _pre_ds_align <= 8

_ds: times DS_SIZE db 0

DS_MASK = _ds or (DS_SIZE - 1)

ds_push:
	mov	[REG_DS], rax
	add	REG_DS, CELL_SIZE
	and	REG_DS, DS_MASK

	ret

ds_pop:
	sub	REG_DS, CELL_SIZE
	and	REG_DS, DS_MASK
	mov	rax, [REG_DS]

	ret

;
;
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
	mov	REG_DS, _ds
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

k_define:
	lodsq
	
	add	REG_LAST, DICT_ENTRY_SIZE
	mov	[REG_LAST], rax
	mov	[REG_LAST + CELL_SIZE], rdi
	
	ret

core_xt:
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

bc_exec_word:
	call	core_xt
	call	rax
	ret

bc_comp_byte:
	movsb
	ret

bc_comp_qword:
	movsq
	ret

bc_ed_nop:
	ret

k_ref_word:
	call	core_xt
	jmp	ds_push

k_setq:
	call	ds_pop
	mov	rbx, rax
	call	ds_pop
	mov	[rbx], rax
	
	ret

bc_tbl:
dq	0x00
dq	k_define
dq	bc_exec_word
dq	k_ref_word
dq	bc_comp_byte
dq	bc_comp_qword
dq	bc_ed_nop

_dict:
dq	"!", k_setq
.last:
dq	"dstsz", k_dstsz

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
