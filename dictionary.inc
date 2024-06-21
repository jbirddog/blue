;
; entry:
;
; 08	- 1 byte flags
;	- 1 byte word len
;	- 6 bytes reserved
; 08	- prev addr
; 08	- code addr
; ??	- remaining word chars
; ??	- stack effects
;

DE_HIDDEN	= 1
DE_IMMEDIATE	= 2

_core_words:
	.b_comma:
	db	DE_IMMEDIATE, 2, 'b,', 0, 0, 0, 0
	dq	0
	dq	_core_code.b_comma
	dq	0
	dq	0 ; TODO: stack effects (( b al -- | rdi ))
	
	.latest:
	.d_comma:
	db	DE_IMMEDIATE, 2, 'd,', 0, 0, 0, 0
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

;
; expects
;	- properly configured blue structure with non zero word len
;
dictionary_find:
	ret
