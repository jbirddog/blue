
format ELF64 executable 3

segment readable writeable executable

CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
DS_ENTRIES = 16
DS_SIZE = DS_ENTRIES * CELL_SIZE
DSI_MASK = DS_ENTRIES - 1
ELF_HEADERS_SIZE = 120
ELF_HEADERS_LOC = $$ - ELF_HEADERS_SIZE

assert DS_ENTRIES and DSI_MASK = 0
assert ELF_HEADERS_LOC = 0x400000

DICT_SIZE = DICT_ENTRY_SIZE * 64
DST_SIZE = 1024
SRC_SIZE = 1024

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12
REG_DSI = r13

SYS_EXIT = 60

entry $

	; read at most a SRC_SIZE of bytecode from stdin
	xor	edi, edi
	mov	rsi, _src
	mov	edx, SRC_SIZE
	xor	eax, eax
	syscall

	mov	REG_SRC, _src
	mov	REG_DST, _dst
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

core_define:
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

k_dspush:
	mov	[_ds + (REG_DSI * CELL_SIZE)], rax
	inc	REG_DSI
	and	REG_DSI, DSI_MASK

	ret

k_dspop:
	dec	REG_DSI
	and	REG_DSI, DSI_MASK
	mov	rax, [_ds + (REG_DSI * CELL_SIZE)]

	ret

k_dstsz:
	mov	rax, REG_DST
	sub	rax, _dst
	jmp	k_dspush

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
	jmp	k_dspush

k_setq:
	call	k_dspop
	mov	rbx, rax
	call	k_dspop
	mov	[rbx], rax
	
	ret

bc_tbl:
dq	0x00
dq	core_define
dq	bc_exec_word
dq	k_ref_word
dq	bc_comp_byte
dq	bc_comp_qword
dq	bc_ed_nop

_ds: times DS_SIZE db 0

_dict:
dq	"!", k_setq
.last:
dq	"dstsz", k_dstsz

rb (DICT_SIZE - ($ - _dict))

_dst: rb DST_SIZE
_src: rb SRC_SIZE
