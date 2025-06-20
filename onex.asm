format ELF64 executable 3

segment readable writeable executable

; from https://flatassembler.net/docs.php?article=fasmg_manual
macro show description,value
	repeat 1, d:value
		display description,`d,13,10
	end repeat
end macro

CELL_SIZE = 8


;;
_tbl:
_0:
	movsb
	ret
	times (CELL_SIZE - ($-_0)) db 0
_1:
	movsd
	ret
	times (CELL_SIZE - ($-_1)) db 0
_2:
	jmp	_dst
	times (CELL_SIZE - ($-_2)) db 0
;;

entry $
	mov	rsi, _src
	mov	rdi, _dst

.loop:
	xor	eax, eax
	
	lodsb
	lea	rdx, [_tbl+(rax*CELL_SIZE)]
	call	rdx

	jmp	.loop

show "onex code size: ", ($ - $$)

_src:

; mov eax, 0x3C
db	0x00, 0xB8
db	0x01, 0x3C, 0x00, 0x00, 0x00

; mov edi, 0x0B
db	0x00, 0xBF
db	0x01, 0x0B, 0x00, 0x00, 0x00

; syscalll
db	0x00, 0x0F
db	0x00, 0x05

; fin
db	0x02

;0:  b8 3c 00 00 00          mov    eax,0x3c
;5:  bf 0b 00 00 00          mov    edi,0xb
;a:  0f 05                   syscall 

_dst rb 1024
