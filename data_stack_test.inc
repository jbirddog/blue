
data_stack_test:
	call data_stack.init
	
	; make sure stack is clean
	call data_stack.depth
	test eax, eax
	jnz .fail
	
	xor edi, edi

	; simple push/pop
	
	inc edi
	mov eax, 5
	call data_stack.push

	call data_stack.depth
	cmp eax, 1
	jne .fail

	xor eax, eax
	call data_stack.pop
	cmp eax, 5
	jne .fail

	call data_stack.depth
	test eax, eax
	jnz .fail

	; multiple push/pops

	inc edi
	mov eax, 7
	call data_stack.push
	mov eax, 9
	call data_stack.push

	xor eax, eax
	call data_stack.pop

	cmp eax, 9
	jne .fail

	mov eax, 11
	call data_stack.push

	call data_stack.depth
	cmp eax, 2
	jne .fail

	xor eax, eax
	call data_stack.pop
	call data_stack.pop

	cmp eax, 7
	jne .fail

	; make sure stack is clean
	call data_stack.depth
	test eax, eax
	jnz .fail

	call data_stack.deinit
	
	ret

	.fail:
	mov eax, 60
	syscall
	ret
