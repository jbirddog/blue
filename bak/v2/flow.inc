;
; expects
;	- word in rax
;
flow_in:
	call	word_input_stack_effects
	mov	rdi, rsi

	.loop:
	dec	ecx
	js	.done

	lea	rbx, [rdi + (rcx * 8)]
	mov	rbx, [rbx]

	cmp	bl, _REGISTER
	jne	.bad_se
	
	and	rbx, REG_MASK
	shr	rbx, REG_OFFSET

	call	data_stack_pop
	cmp	eax, _IMMEDIATE
	jne	.flow_reg

	.flow_lit:
	mov	al, 0xb8
	add	al, bl
	call	b_comma

	call	data_stack_pop
	call	d_comma

	jmp	.loop

	.flow_reg:
	and	ebx, 7
	
	and	rax, REG_MASK
	shr	rax, REG_OFFSET
	and	eax, 7
	shl	eax, 3

	or	ebx, eax
	or	ebx, 0xc0

	mov	al, 0x89
	call	b_comma

	mov	al, bl
	call	b_comma
	
	jmp	.loop
	
	.done:
	ret

	.bad_se:
	die	ERR_BAD_SE

;
; expects
;	- word in rax
;
push_flow_in:
	call	word_input_stack_effects

	.loop:
	dec	ecx
	js	.done

	lea	rax, [rsi + (rcx * 8)]
	mov	rax, [rax]

	call	data_stack_push
	jmp	.loop
	
	.done:
	ret
	
;
; expects
;	- word in rax
;
flow_out:
	ret
