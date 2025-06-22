;
; TODOs:
;
; * If the 0x00 dict entry has a `not_found` addr in cell 2, not found could be handled like found
; * Move SIZE_ prefix to suffix
; * Remove BC_ constants and inline bytecode
; * Add length bits so BC_COMP_BYTE is BC_COMP_NUM | BYTES_1
;

format ELF64 executable 3

segment readable writeable executable

BC_FIN = 0x00
BC_DEFINE_WORD = 0x01
BC_EXEC_WORD = 0x02
BC_COMP_BYTE = 0x03

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

SIZE_BLK = 1024
SIZE_CELL = 8
SIZE_DICT_ENTRY = SIZE_CELL * 2
SIZE_ELF_HEADERS = 120

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

core_define:
	lodsq
	
	add	REG_LAST, SIZE_DICT_ENTRY
	mov	[REG_LAST], rax
	mov	[REG_LAST + SIZE_CELL], rdi
	
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
	
	sub	REG_LAST, SIZE_DICT_ENTRY
	jmp	.find

.found:
	mov	rax, [REG_LAST + SIZE_CELL]
	
.done:
	pop	REG_LAST
	ret

bc_exec_word_impl:
	call	core_xt
	call	rax
	ret

bc_comp_byte_impl:
	movsb
	ret

bc_tbl:
dq	0x00
dq	core_define
dq	bc_exec_word_impl
dq	bc_comp_byte_impl

entry $
	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_LAST, dict.last

.loop:
	xor	eax, eax
	lodsb

	test	al, al
	jz	.exit
	
	call	qword [bc_tbl + (rax * SIZE_CELL)]
	jmp	.loop

.exit:
	;call _dst
	sub rdi, _dst
	mov eax, 60
	syscall

show "code size: ", ($ - $$)
times (SIZE_BLK - ($ - $$ + SIZE_ELF_HEADERS)) db 0

dict:
dq	0x00, 0x00
.last:
dq	"??", 0x00

times (SIZE_BLK - ($ - dict)) db 0

_src:

db	BC_DEFINE_WORD
dq	"exit"

; 31 c0			xor    eax,eax
db	BC_COMP_BYTE
db	0x31
db	BC_COMP_BYTE
db	0xC0

; b0 3c                   mov    al,0x3c
db	BC_COMP_BYTE
db	0xB0
db	BC_COMP_BYTE
db	0x3C

; 40 b7 03                mov    dil,0x3
db	BC_COMP_BYTE
db	0x40
db	BC_COMP_BYTE
db	0xB7
db	BC_COMP_BYTE
db	0x03

; 0f 05                   syscall
db	BC_COMP_BYTE
db	0x0F
db	BC_COMP_BYTE
db	0x05

; call previously defined word
db	BC_EXEC_WORD
dq	"exit"

times (SIZE_BLK - ($ - _src)) db 0

_dst:
times (SIZE_BLK - ($ - _dst)) db 0
