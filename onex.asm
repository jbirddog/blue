;
; TODOs:
;
; * Move to just having one number type, 8 bytes editor change choose how to display
;   - BC_COMP_BYTE/bc_comp_byte -> comp_num
;
; * BC_EXEC_NUM
; * Put data stack in block 0
; * Top of stack always in rax?
;
; * Dict entry 0x00 can have not found handler
; * Limit dict entry cell 1 values to 7 chars, use 1 byte for flags, etc
;
; * Get prototype editor screen working
; * Once editor is prototyped, port to onex
;
; * Port bth to onex
;   - Block 1 for bth logic
;   - Concat with block 0, mmap file from argv[1] and set src
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
PAGE_SIZE = 4096

BC_FIN = 0x00
BC_DEFINE_WORD = 0x01
BC_EXEC_WORD = 0x02
BC_COMP_BYTE = 0x03
BC_ED_NL = 0x04

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

bc_ed_nop:
	ret

bc_tbl:
dq	0x00
dq	core_define
dq	bc_exec_word
dq	bc_comp_byte
dq	bc_ed_nop

entry $
	mov	REG_SRC, block_1
	lea	REG_LAST, [REG_SRC + BLK_SIZE]
	lea	REG_DST, [REG_SRC + (BLK_SIZE * 2)]

	call	core_load
	
	xor	edi, edi
	mov	eax, SYS_EXIT
	syscall
	
show "code size: ", ($ - $$)
times (BLK_SIZE - ($ - $$ + ELF_HEADERS_SIZE)) db 0

block_1:

; bth port
; - define words
;   - plan
;   - ok
;   - notok
;   - done
; - open argv[1]
; - read test input block into buffer
; - set dst to output buffer
; - load test input block from buffer
; - write output buffer to stdout
;
; - prove sample test with plan '01'; ok; done

;
; - will be using the onex block 0 so can use its allocations
; - block 1 is bth source
; - 
;

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
db	BC_COMP_BYTE, 0x03

; 0f 05			syscall
db	BC_COMP_BYTE, 0x0F
db	BC_COMP_BYTE, 0x05

db	BC_EXEC_WORD
dq	"exit"

show "block_1 size: ", ($ - block_1)
times (BLK_SIZE - ($ - block_1)) db 0

rb (BLK_SIZE * 6)
