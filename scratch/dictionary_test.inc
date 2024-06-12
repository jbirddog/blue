
dictionary_test:
	call dictionary.init

	; test dictionary init's properly
	
	mov edi, 1
	mov rax, [_dictionary.base]
	cmp rax, [_dictionary.here]
	jne .fail
	
	mov edi, 2
	mov rax, [_dictionary.latest]
	cmp rax, _core_words.latest
	jne .fail
	
	call dictionary.deinit
	ret

	.fail:
	mov eax, 60
	syscall
	ret
