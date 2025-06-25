;
; TODOs:
;
; * If the 0x00 dict entry has a `not_found` addr in cell 2, not found could be handled like found
; * Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
; * Need BC_EXEC_NUM
; * Mmap dict (rw)
; * Block 0 doesn't need to be writable if use registers/stack as storage
;   - Start with argv, argc on stack
; * Get prototype editor screen working
; * Once editor is prototyped, port to onex
; * Port bth to onex
;   - Block 1 for bth logic
;   - Concat with Block 0, mmap file from argv[1] and set src
;   - Mmap for test output
;
; - Keep in mind there is no ip - just compiling byte code top to bottom
; - Control flow happens via compiled machine code
; - An outbut binary can optional build on Block 0 to opt-in to the onex "runtime"
; - Return stack is rsp
;

format ELF64 executable 3

segment readable writeable executable

MAP_ANONYMOUS = 32
MAP_PRIVATE = 2

PROT_READ = 1
PROT_WRITE = 2
PROT_EXEC = 4

PROT_RW = PROT_READ or PROT_WRITE
PROT_RWX = PROT_RW or PROT_EXEC

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

SYS_EXIT = 60
SYS_MMAP = 9

BLK_SIZE = 1024
CELL_SIZE = 8
DICT_ENRTY_SIZE = CELL_SIZE * 2
ELF_HEADERS_SIZE = 120
PAGE_SIZE = 4096

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

syscall_or_die:
	syscall

	cmp	rax, 0
	jge	.done
	
	neg	rax
	mov	edi, eax
	jmp	exit

.done:
	ret

;
; expects
;	- status in edi
exit:
	mov	eax, SYS_EXIT
	syscall

;
; expects
;	- buffer prot flags in edx
; returns
;	- addr in rax
;
mmap_buffer:
	xor	edi, edi
	mov	esi, PAGE_SIZE
	mov	r10d, MAP_ANONYMOUS or MAP_PRIVATE
	mov	r8d, -1
	xor	r9d, r9d
	mov	eax, SYS_MMAP
	call	syscall_or_die

	ret

core_define:
	lodsq
	
	add	REG_LAST, DICT_ENRTY_SIZE
	mov	[REG_LAST], rax
	mov	[REG_LAST + CELL_SIZE], rdi
	
	ret

core_xt:
	lodsq
	push	REG_LAST
.find:
	mov	rbx, [REG_LAST]
	cmp	rax, rbx
	je	.found

	test	rbx, rbx
	jz	.done
	
	sub	REG_LAST, DICT_ENRTY_SIZE
	jmp	.find

.found:
	mov	rax, [REG_LAST + CELL_SIZE]
	
.done:
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
	mov	REG_LAST, dict.last

	mov	edx, PROT_RWX
	call	mmap_buffer
	mov	REG_DST, rax
	
	mov	REG_SRC, _src

.loop:
	xor	eax, eax
	lodsb

	test	al, al
	jz	.exit
	
	call	qword [bc_tbl + (rax * CELL_SIZE)]
	jmp	.loop

.exit:
	xor	edi, edi
	jmp	exit
	
show "code size: ", ($ - $$)
times (BLK_SIZE - ($ - $$ + ELF_HEADERS_SIZE)) db 0

dict:
dq	0x00, 0x00
.last:
dq	"??", 0x00

times (BLK_SIZE - ($ - dict)) db 0

_src:

file "test.blk"

times (BLK_SIZE - ($ - _src)) db 0
