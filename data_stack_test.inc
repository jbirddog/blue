
data_stack_test:
	xor edi, edi

	; simple push/pop
	
	inc edi
	mov eax, 5
	call data_stack.push

	xor eax, eax
	call data_stack.pop

	cmp eax, 5
	jne .fail

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

	xor eax, eax
	call data_stack.pop
	call data_stack.pop

	cmp eax, 7
	jne .fail
	
	ret

	.fail:
	mov eax, 60
	syscall
	ret
