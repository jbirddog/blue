format elf64 executable 3

segment readable writable executable

tib dq 0

code_buffer:
_op_00:
	; ( -- b ) - read byte from input, push on the data stack
	ret
	times 15 db 0
	assert ($ - code_buffer) and 15 = 0

entry $	
	db 0xbf, 0x0b, 0x00, 0x00, 0x00
  	db 0xb8, 0x3c, 0x00, 0x00, 0x00
  	db 0x0f, 0x05
	;rb 1024
