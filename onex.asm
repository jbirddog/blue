format ELF64 executable 3

segment readable writeable executable

BC_EXEC_WORD = 0x00

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

core_fin:
	mov	edi, 17
	mov	eax, 60
	syscall

core_xt:
	lodsq
	push	REG_LAST
.find:
	cmp	rax, [REG_LAST]
	mov	rax, [REG_LAST + 8]
	je	.done

	sub	REG_LAST, 16
	test	rax, rax
	jnz	.find

.done:
	pop	REG_LAST
	ret

bc_exec_word_impl:
	call	core_xt
	call	rax
	ret

bc_tbl:
dq	bc_exec_word_impl

entry $
	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_LAST, dict.last

	xor	eax, eax
	lodsb
	call	qword [bc_tbl + (rax * 8)]

.exit:
	mov edi, 9
	mov eax, 60
	syscall

show "code size: ", ($ - $$)

_src:
db	BC_EXEC_WORD
dq	"fin"

_dst:
times (SIZE_BLK - ($ - _dst)) db 0

dict:
dq	0, 0
.last:
dq	"fin", core_fin

times (SIZE_BLK - ($ - dict)) db 0
