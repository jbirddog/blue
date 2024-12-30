format elf64 executable 3

segment readable writable executable

DATA_STACK_SIZE = 64
USER_CODE_BUFFER_SIZE = 1024
WORD_SIZE = 16

tib dq 0

read_input:
	;
	; expects buffer size in edx
	;
	xor eax, eax
	xor edi, edi
	mov rsi, tib
	syscall

	; TODO: exit on error
	; TODO: exit on bytes read != edx
	
	ret

entry $	
	db 0xbf, 0x0b, 0x00, 0x00, 0x00
  	db 0xb8, 0x3c, 0x00, 0x00, 0x00
  	db 0x0f, 0x05

code_buffer:
_op_00:
	; ( -- b ) - read byte from input, push on the data stack
	mov edx, 1
	call read_input
	ret

	assert ($ - _op_00) <= WORD_SIZE
	times (WORD_SIZE - ($ - _op_00)) db 0
	assert ($ - _op_00) = WORD_SIZE

;
; everything below here needs to be r* else bytes will be in the binary
;
	
rb USER_CODE_BUFFER_SIZE

data_stack rq DATA_STACK_SIZE
