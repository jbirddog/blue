;
; expects
;	- word in rax
;
flow_in:
	call	word_input_stack_effects
	mov	edi, esi
	
	.loop:
	dec	ecx
	js	.done

	lea	ebx, [edi + (ecx * 8)]
	mov	ebx, [ebx]
	and	ebx, REG_MASK
	shr	ebx, REG_OFFSET

	call	data_stack_pop
	cmp	eax, _IMMEDIATE
	jne	.flow_reg

	mov	al, 0xb8
	add	al, bl
	call	b_comma

	call	data_stack_pop
	call	d_comma

	jmp	.loop

	.flow_reg:
	die	ERR_NO_IMPL
	
	.done:
	ret

;
; expects
;	- word in rax
;
flow_out:
	ret
