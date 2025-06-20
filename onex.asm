format ELF64 executable 3

segment readable writeable executable

OP_SIZE = 8

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

;;

op_tbl:

macro op n
op_##n = $ - op_tbl
end macro

macro end_op
	times (OP_SIZE - (($ - op_tbl) mod OP_SIZE)) db 0
end macro

op	cpb	;	( -- )	copy byte from src to dst
	movsb
	ret
end_op

op	cpd	;	( -- )	copy dword from src to dst
	movsd
	ret
end_op

op	fin	;	( -- )	TMP
	jmp	_dst
end_op

assert (($ - op_tbl) mod OP_SIZE) = 0
;;

entry $
	mov	rsi, _src
	mov	rdi, _dst

.loop:
	xor	eax, eax
	
	lodsb
	add	rax, op_tbl
	call	rax

	jmp	.loop

show "onex code size: ", ($ - $$)

_src:

; mov eax, 0x3C
db	op_cpb, 0xB8
db	op_cpd, 0x3C, 0x00, 0x00, 0x00

; mov edi, 0x0B
db	op_cpb, 0xBF
db	op_cpd, 0x0B, 0x00, 0x00, 0x00

; syscalll
db	op_cpb, 0x0F
db	op_cpb, 0x05

; fin
db	op_fin

show "bytecode size: ", ($ - _src)

_dst rb 1024
