format elf64 executable 3

segment readable writeable

include "defs.inc"

segment readable executable

include "linux.inc"
include "code_buffer.inc"
include "dictionary.inc"

entry $
	call dictionary_init

	; test dictionary init's properly
	
	mov	edi, 1
	mov	rax, [_dictionary.base]
	cmp	rax, [_dictionary.here]
	jne	exit
	
	mov	edi, 2
	mov	rax, [_dictionary.latest]
	cmp	rax, _core_words.latest
	jne	exit
	
	call	dictionary_deinit

	xor	edi, edi
	
exit:
	mov	eax, 60
	syscall
