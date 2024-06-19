
;
; expects
;	- properly configured _blue structure
;
parser_next_word:
	mov	[_blue.word_len], 0

	mov	ecx, [_blue.tib_len]
	test	ecx, ecx
	jz	.done

	mov	eax, [_blue.tib_in]
	sub	ecx, eax
	jng	.done

	and	ecx, 0xFF
	push	rcx

	mov	rsi, _blue.tib
	add	esi, eax
	mov	rdi, _blue.word

	call	_skip_ws

	test	ecx, ecx
	jz	.set_tib_in

	.loop:
	lodsb
	cmp	al, 32
	jle	.loop_done

	stosb
	dec	ecx
	jnz	.loop
	
	.loop_done:
	sub	rdi, _blue.word
	mov	[_blue.word_len], dil

	.set_tib_in:
	pop	rax
	sub	eax, ecx
	add	[_blue.tib_in], eax
	
	.done:
	ret
	
_skip_ws:
	lodsb
	cmp	al, 32
	jg	.done

	dec	ecx
	jnz	_skip_ws

	.done:
	dec	rsi
	ret
