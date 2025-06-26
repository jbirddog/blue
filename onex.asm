;
; TODOs:
;
; * Put the data stack in block 0 with bc_tbl
; * Dict entry 0x00 can have not found handler
; * Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
; * Need BC_EXEC_NUM
; * Get prototype editor screen working
; * Once editor is prototyped, port to onex
; * Port bth to onex
;   - Block 1 for bth logic
;   - Concat with Block 0, mmap file from argv[1] and set src
;   - Mmap for test output
;
; - Keep in mind there is no ip - just compiling byte code top to bottom
; - Control flow happens via compiled machine code
; - An outbut binary can chose to build on Block 0 to opt-in to the onex "runtime"
; - Return stack is rsp
;

format ELF64 executable 3

segment readable writeable executable

BLK_SIZE = 1024
CELL_SIZE = 8
DICT_ENTRY_SIZE = CELL_SIZE * 2
ELF_HEADERS_SIZE = 120

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

SYS_EXIT = 60

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

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

bc_tbl:
dq	0x00
dq	core_define
dq	bc_exec_word
dq	bc_comp_byte

entry $	
	mov	REG_SRC, _src
	mov	REG_LAST, _dict
	mov	REG_DST, _dst

	call	core_load

	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall
	
show "code size: ", ($ - $$)
times (BLK_SIZE - ($ - $$ + ELF_HEADERS_SIZE)) db 0

_src:
file "test.blk"
assert  $ - _src = BLK_SIZE

_dict rb BLK_SIZE
_dst rb BLK_SIZE
