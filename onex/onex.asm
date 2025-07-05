
format ELF64 executable 3

segment readable writeable executable

include "bc.inc"

BLK_SIZE = 1024
CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
ELF_HEADERS_SIZE = 120

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

entry $
	call	mmap_rwx_buf

	mov	REG_SRC, block_1
	
	mov	REG_LAST, rax
	lea	REG_DST, [rax + (BLK_SIZE * 2)]

	push	REG_DST

	call	core_load
	
	push	REG_DST

	; write elf headers
	xor	edi, edi
	inc	edi
	lea	rsi, [block_1 - BLK_SIZE]
	mov	edx, 120
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

;;;;

include "linux.inc"

;;;;

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
	
times (BLK_SIZE - ($ - $$ + ELF_HEADERS_SIZE)) db 0

block_1:

db	BC_DEFINE_WORD
dq	"exit"

; 31 c0			xor    eax,eax
db	BC_COMP_BYTE, 0x31
db	BC_COMP_BYTE, 0xC0

; b0 3c			mov    al,0x3c
db	BC_COMP_BYTE, 0xB0
db	BC_COMP_BYTE, 0x3C

; 40 b7 03		mov    dil,0x3
db	BC_COMP_BYTE, 0x40
db	BC_COMP_BYTE, 0xB7
db	BC_COMP_BYTE, 0x33

; 0f 05			syscall
db	BC_COMP_BYTE, 0x0F
db	BC_COMP_BYTE, 0x05

;db	BC_EXEC_WORD
;dq	"exit"

times (BLK_SIZE - ($ - block_1)) db 0

rb (BLK_SIZE * 6)
