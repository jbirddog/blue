
data_stack_test:
	call	data_stack_init

	t 'initial data stack has depth of 0'

	call	data_stack_depth
	test	eax, eax
	jnz	failure

	ok

	t 'data stack with 1 item has depth of 1'
	
	mov	eax, 5
	call	data_stack_push

	call	data_stack_depth
	cmp	eax, 1
	jne	failure

	ok

	t 'can pop a previously pushed value'
	
	call	data_stack_pop
	cmp	eax, 5
	jne	failure

	ok

	t 'empty data stack has depth of 0'
	
	call	data_stack_depth
	test	eax, eax
	jnz	failure

	ok

	t 'pops the right value after multiple pushes'
	
	mov	eax, 7
	call	data_stack_push
	mov	eax, 9
	call	data_stack_push

	xor	eax, eax
	call	data_stack_pop

	cmp	eax, 9
	jne	failure

	ok

	t 'has correct depth after unbalanced pushes and pops'
	
	mov	eax, 11
	call	data_stack_push

	call	data_stack_depth
	cmp	eax, 2
	jne	failure

	ok

	t 'pops the right value after multiple pops'
	
	call	data_stack_pop
	call	data_stack_pop

	cmp	eax, 7
	jne	failure

	ok

	t 'has a depth of 0 after balanced pushes and pops'

	call	data_stack_depth
	test	eax, eax
	jnz	failure

	ok

	call data_stack_deinit

	ret
