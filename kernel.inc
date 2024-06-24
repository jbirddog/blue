
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
	
	test	eax, eax
	jz	.number_or_die

	; TODO: its a word, call/compile it...

	jmp	.loop
	
	.number_or_die:
	call	to_number

	cmp	eax, SUCCESS
	jne	.not_a_word

	mov	eax, edi
	call	data_stack_push

	jmp	.loop

	.not_a_word:
	mov	edi, ERR_NOT_A_WORD
	ret

	.done:
	ret

kernel_deinit:
	call	dictionary_deinit
	call	data_stack_deinit
	call	code_buffer_deinit
	ret
