format ELF64 executable 3

segment readable writeable executable

SIZE_BLK = 1024

REG_SRC = rsi
REG_DST = rdi
REG_LAST = r12

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

entry $
	mov	REG_SRC, _src
	mov	REG_DST, _dst
	mov	REG_LAST, _last

	; TODO: check byte for what to do
	lodsb
	lodsq
	
	push	REG_LAST
.find:
	cmp	rax, [REG_LAST]
	je	.call

	mov	rax, [REG_LAST]
	test	rax, rax
	jz	.not_found
	jmp	.find
	
.call:
	call	qword [REG_LAST + 8]
	pop	REG_LAST

.not_found:
.exit:
	mov edi, 9
	mov eax, 60
	syscall

show "code size: ", ($ - $$)

_src:
db	0x00
dq	"fin"

_dst:
_core_fin:
	mov	edi, 17
	mov	eax, 60
	syscall
	
times (SIZE_BLK - ($ - _dst)) db 0

_lookup:
dq	0, 0
_last:
dq	"fin", _core_fin

times (SIZE_BLK - ($ - _lookup)) db 0
