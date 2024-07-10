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
	jmp	.loop
	
	.done:
	ret

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
	and	rax, REG_MASK
	shr	rax, REG_OFFSET

	call	data_stack_push
	
	.done:
	ret
	
;
; expects
;	- word in rax
;
flow_out:
	ret
