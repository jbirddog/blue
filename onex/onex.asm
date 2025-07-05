
format ELF64 executable 3

segment readable writeable executable

BLK_SIZE = 1024
CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
ELF_HEADERS_SIZE = 120
PAGE_SIZE = 4096

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

SYS_EXIT	= 60

entry $
	xor	edi, edi
	mov	rsi, _src
	mov	edx, BLK_SIZE
	xor	eax, eax
	syscall

	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_LAST, _dict

	push	REG_DST

	call	core_load
	
	push	REG_DST

	; write elf headers
	xor	edi, edi
	inc	edi
	mov	rsi, $$ - ELF_HEADERS_SIZE
	mov	edx, ELF_HEADERS_SIZE
	mov	eax, edi
	syscall

	; write assembled code
	pop	rdx
	pop	rsi
	
	xor	edi, edi
	inc	edi
	sub	rdx, rsi
	mov	eax, edi
	syscall
	
	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall


core_load:
.loop:
	xor	eax, eax
	lodsb

	test	al, al
	jz	.exit
	
	call	qword [bc_tbl + (rax * CELL_SIZE)]
	jmp	.loop

.exit:
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

bc_exec_word:
	call	core_xt
	call	rax
	ret

bc_comp_byte:
	movsb
	ret

bc_ed_nop:
	ret

bc_tbl:
dq	0x00
dq	core_define
dq	bc_exec_word
dq	bc_comp_byte
dq	bc_ed_nop

_dict: rb BLK_SIZE
_dst: rb BLK_SIZE
_src: rb BLK_SIZE
