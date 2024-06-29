;
; expects
;	- properly configured blue structure with non zero word len
;
to_number:
	xor	eax, eax
	xor	edi, edi
	
	mov	cl, [_blue.word_len]
	mov	rsi, _blue.word

	xor	ebx, ebx
	mov	bl, [_blue.base]

	cmp	bl, 10
	je	.base10_loop

	cmp	bl, 16
	je	.base16_loop

	die	ERR_BAD_BASE
	
	.failure:
	mov	eax, FAILURE
	ret

	.success:
	mov	eax, SUCCESS
	ret

	;
	; decimal
	;
	
	.base10_loop:
	lodsb

	cmp	al, 57
	jg	.failure

	sub	al, 48
	js	.failure

	xchg	eax, edi
	mul	ebx
	xadd	edi, eax

	dec	cl
	jnz	.base10_loop
	jmp	.success

	;
	; hex
	;
	
	.base16_loop:
	lodsb

	cmp	al, 57
	jg	.base16_AF

	sub	al, 48
	js	.failure

	.base16_mul:
	xchg	eax, edi
	mul	ebx
	xadd	edi, eax

	dec	cl
	jnz	.base16_loop
	jmp	.success

	.base16_AF:
	cmp	al, 70
	jg	.failure

	sub	al, 55
	cmp	al, 10
	jl	.failure

	jmp	.base16_mul

