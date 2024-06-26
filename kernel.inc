
kernel_init:
	call	code_buffer_init
	call	data_stack_init
	call	dictionary_init

	mov	[_blue.base], 10
	call	_interpret
	
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
	jz	.number_or_bail

	call	_handle_word
	jmp	.loop
	
	.number_or_bail:
	call	to_number
	cmp	eax, SUCCESS
	jne	.not_a_word

	mov	eax, edi
	call	data_stack_push
	jmp	.loop

	.done:
	call	_interpretive_dance
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

_interpret:
	mov	rdi, [_code_buffer.here]
	mov	[_code_buffer.mark], rdi

	add	rdi, _code_buffer.interpret_offset
	mov	[_code_buffer.here], rdi
	
	mov	[_blue.mode], INTERPRET
	ret

_interpretive_dance:
	mov	al, 0xc3
	call	_core_code.b_comma

	mov	rsi, [_code_buffer.mark]
	add	rsi, _code_buffer.interpret_offset

	mov	rdi, [_code_buffer.mark]
	mov	[_code_buffer.here], rdi

	xor	rdi, rdi
	mov	[_code_buffer.mark], rdi

	call	rsi
	
	ret

_compile:
	call	_interpretive_dance

	mov	[_blue.mode], COMPILE
	ret

;
; expects
;	- word in rax
;
_flow_in:
	mov	al, 0xb8
	call	_core_code.b_comma

	call	data_stack_pop
	call	_core_code.d_comma

	ret

;
; expects
;	- word in rax
;
_flow_out:
	ret

;
; expects
;	- word in rax
;
_handle_word:
	push	rax
	push	rax
	call	_flow_in

	mov	al, 0x48_
	call	_core_code.b_comma
	mov	al, 0xc7
	call	_core_code.b_comma
	mov	al, 0xc7
	call	_core_code.b_comma

	pop	rax
	add	rax, _dictionary.code_offset
	mov	rax, [rax]
	call	_core_code.d_comma

	mov	al, 0xff
	call	_core_code.b_comma
	mov	al, 0xd7
	call	_core_code.b_comma

	pop	rax
	call	_flow_out
	
	ret
