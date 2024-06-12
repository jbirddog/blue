
code_buffer_test:
	call code_buffer.init

	; test code_buffer init's properly
	
	mov edi, 1
	mov rax, [_code_buffer.base]
	cmp rax, [_code_buffer.here]
	jne .fail

	; test b, writes a byte

	mov al, 123
	call _core_code.b_comma
	
	mov edi, 2
	mov rax, [_code_buffer.base]
	mov rcx, [_code_buffer.here]
	sub rcx, rax
	cmp ecx, 1
	jne .fail

	mov edi, 3
	mov rax, [rax]
	cmp al, 123
	jne .fail

	; test d, writes a dword

	mov eax, 123456
	call _core_code.d_comma

	mov edi, 4
	mov rax, [_code_buffer.base]
	inc rax
	mov rcx, [_code_buffer.here]
	sub rcx, rax
	cmp ecx, 4
	jne .fail

	mov edi, 5
	mov rax, [rax]
	cmp eax, 123456
	jne .fail

	call code_buffer.deinit
	ret

	.fail:
	mov eax, 60
	syscall
	ret
