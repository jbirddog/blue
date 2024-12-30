format elf64 executable 3

segment readable writable executable

cb:
	; nop
	ret
	times 15 db 0
	assert ($ - cb) and 15 = 0

	; byte to cb
	
entry $	
	db 0xbf, 0x0b, 0x00, 0x00, 0x00
  	db 0xb8, 0x3c, 0x00, 0x00, 0x00
  	db 0x0f, 0x05
	;rb 1024
