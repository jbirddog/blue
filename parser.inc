
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

	mov	rsi, _blue.tib
	add	esi, eax
	mov	rdi, _blue.word

	call	_skip_ws

	test	ecx, ecx
	jz	.loop_done

	.loop:
	lodsb
	cmp	al, 32
	jle	.loop_done

	stosb
	dec	ecx
	jnz	.loop
	
	.loop_done:
	; need to set word_len
	; need to set tib_in
	
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
	inc	ecx
	ret
