;
; entry:
;
; 08 - 1 byte flags
;    - 1 byte word length
;    - 6 bytes first chars
; 08 - prev addr
; 08 - code addr
; 08 - 1 byte length of remaining word chars
;    - 7 bytes reserved
; ?? - remaining word chars
; ?? - stack effects
;

DE_VIS		= 1
DE_IMMED	= 2

_core_words:
	.b_comma:
	db	DE_VIS or DE_IMMED, 2, 'b,', 0, 0, 0, 0
	dq	0
	dq	_core_code.b_comma
	dq	0
	dq	0 ; TODO: stack effects (( b al -- | rdi ))
	
	.latest:
	.d_comma:
	db	DE_VIS or DE_IMMED, 2, 'd,', 0, 0, 0, 0
	dq	.b_comma
	dq	_core_code.d_comma
	dq	0
	dq	0 ; TODO: stack effects (( d ax -- | rdi ))

dictionary_init:
	mov	esi, _dictionary.length
	mov	edx, PROT_RW
	call	mmap_buffer

	mov	rdi, _dictionary.base
	stosq
	stosq
	
	mov	[_dictionary.latest], _core_words.latest

	ret

dictionary_deinit:
	mov	esi, _dictionary.length
	mov	rdi, [_dictionary.base]
	mov	eax, SYS_MUNMAP
	syscall
	
	ret
