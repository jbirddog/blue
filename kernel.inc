
kernel_init:
	call	code_buffer_init
	call	data_stack_init
	call	dictionary_init

	mov	[_blue.base], 10
	mov	[_blue.mode], INTERPRET
	
	ret

;
; expects
;	- tib value in rsi
;	- tib length in ecx
;	- tib in in eax
;
kernel_loop:
	mov	[_blue.tib], rsi
	mov	[_blue.tib_len], ecx
	mov	[_blue.tib_in], eax

	.loop:
	call	parser_next_word
	cmp	[_blue.word_len], 0
	je	.done

	call	dictionary_find
	test	rax, rax
	jz	.number_or_bail

	call	_handle_word
	jmp	.loop
	
	.number_or_bail:
	call	to_number
	cmp	eax, SUCCESS
	jne	.not_a_word

	mov	eax, edi
	call	data_stack_push

	mov	eax, _IMMEDIATE
	call	data_stack_push
	jmp	.loop

	.done:
	mov	eax, SUCCESS
	ret

	.not_a_word:
	mov	edi, ERR_NOT_A_WORD
	ret

kernel_deinit:
	call	dictionary_deinit
	call	data_stack_deinit
	call	code_buffer_deinit
	ret

;
; expects
;	- word in rax
;
_compile_word:
	push	rax
	call	flow_in

	mov	al, 0x48
	call	b_comma
	mov	al, 0xc7
	call	b_comma
	mov	al, 0xc7
	call	b_comma

	pop	rax
	add	rax, _dictionary.code_offset
	mov	rax, [rax]
	call	d_comma

	mov	al, 0xff
	call	b_comma
	mov	al, 0xd7
	call	b_comma

	ret

;
; expects
;	- word in rax
;
_interpret_word:
	push	[_code_buffer.here]

	call	_compile_word

	mov	al, 0xc3
	call	b_comma

	pop	rsi
	mov	[_code_buffer.here], rsi
	call	rsi

	ret

;
; expects
;	- word in rax
;
_handle_word:
	cmp	[_blue.mode], INTERPRET
	je	.interpret

	mov	rsi, [rax]
	test	sil, DE_IMMEDIATE
	jnz	.interpret

	call	_compile_word
	jmp	.done

	.interpret:
	call	_interpret_word

	.done:
	ret
