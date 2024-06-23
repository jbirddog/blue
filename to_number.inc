;
; expects
;	- properly configured blue structure with non zero word len
;
to_number:
	xor	eax, eax
	xor	ecx, ecx
	xor	edi, edi
	xor	edx, edx
	
	mov	cl, [_blue.word_len]
	mov	rsi, _blue.word
	mov	dl, [_blue.base]

	.loop:
	lodsb

	cmp	al, 48
	jl	.failure

	cmp	al, 57
	jg	.failure

	sub	al, 48

	xchg	eax, edi
	mul	edx
	add	eax, edi
	xchg	eax, edi

	dec	cl
	jnz	.loop

	mov	eax, SUCCESS
	ret

	.failure:
	xor	edi, edi
	mov	eax, FAILURE
	ret
