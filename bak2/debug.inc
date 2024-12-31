
dump_code_buffer:
	mov	rdi, _code_buffer_dump_file
	mov	esi, 0x01 or 0x40 or 0x200
	mov	edx, 0x1ed
	mov	eax, SYS_OPEN
	syscall

	mov	rdi, rax
	mov	rsi, [_code_buffer.base]
	mov	rdx, [_code_buffer.here]
	sub	rdx, rsi
	mov	eax, SYS_WRITE
	syscall
	
	mov	eax, SYS_CLOSE
	syscall
	
	ret

_code_buffer_dump_file:
	db	"code_buffer_dump.out"
	db	0x00

H db 'H'
newline db 10

print_char:
	mov	edx, 1

print:
	mov	edi, STDOUT_FILENO
	mov	eax, SYS_WRITE
	syscall
	ret

print_word:
	push	rax
	push	rcx
	push	rdi
	push	rdx
	push	rsi

	xor	edx, edx
	mov	dl, [_blue.word_len]
	mov	esi, _blue.word
	call	print

	mov	esi, newline
	call	print_char

	pop	rsi
	pop	rdx
	pop	rdi
	pop	rcx
	pop	rax

	ret
	
here:
	push	rax
	push	rcx
	push	rdi
	push	rdx
	push	rsi
	
	mov	esi, H
	call	print_char

	mov	esi, newline
	call	print_char

	pop	rsi
	pop	rdx
	pop	rdi
	pop	rcx
	pop	rax

	ret

