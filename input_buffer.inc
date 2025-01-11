
input_buffer_bytes_available:
	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET

	mov	rcx, [rsi + VM_DATA_OFFSET_INPUT_BUFFER_LOCATION]
	sub	rcx, [rsi + VM_DATA_OFFSET_INPUT_BUFFER_HERE_LOCATION]
	add	rcx, [rsi + VM_DATA_OFFSET_INPUT_BUFFER_SIZE]

	ret

; expects bytes to read in eax
input_buffer_read_bytes:
	call	input_buffer_bytes_available
	xor	esi, esi
	cmp	ecx, eax
	cmovl	ecx, esi
	jl	.done

	mov	rsi, [mem]
	add	rsi, VM_DATA_OFFSET + VM_DATA_OFFSET_INPUT_BUFFER_HERE_LOCATION
	push	rsi
	mov	rsi, [rsi]
	
	; TODO: lods* for other byte counts
	lodsb

	pop	rdi
	mov	[rdi], rsi
	
.done:
	ret

input_buffer_read_byte:
	xor	eax, eax
	inc	eax
	call	input_buffer_read_bytes
	
	ret
