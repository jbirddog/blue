format ELF64 executable 3

segment readable writeable executable

BC_FIN = 0x00
BC_EXEC_WORD = 0x01
BC_COMP_BYTE = 0x02

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

SIZE_BLK = 1024

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

core_cpb:
	movsb
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
	
	sub	REG_LAST, 16
	jmp	.find

.found:
	mov	rax, [REG_LAST + 8]
	
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
	
	call	qword [bc_tbl + (rax * 8)]
	jmp	.loop

.exit:
	call _dst
	sub rdi, _dst
	mov eax, 60
	syscall

show "code size: ", ($ - $$)

_src:
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

; ret
db	BC_COMP_BYTE
db	0xC3

times (SIZE_BLK - ($ - _src)) db 0

_dst:
times (SIZE_BLK - ($ - _dst)) db 0

dict:
dq	0, 0
.last:
dq	"cpb", core_cpb

times (SIZE_BLK - ($ - dict)) db 0
