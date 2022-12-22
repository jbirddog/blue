format ELF64 executable 3 ; fasm q: why 3? can omit or change

;
; configuration
;

config:

.cell_size = 8
.input_buffer_size = 4096
.max_data_stack_items = 32
.max_user_words = 1024
.word_code_size = 32

; needed in asm - generic words to support
;
; * read until c from input buffer
; * create dictionary entry
; * update dictionary entry
; * find dictionary entry
; * call dictionary entry
; * write bytes to code buffer
; * drop/dup/swap

segment readable writeable executable

;
; code buffer
;

code_buffer:
.cap = config.word_code_size * config.max_user_words
rb .cap
.end:

segment readable writeable

;
; compile time data stack
;

data_stack:
.cap = config.cell_size * config.max_data_stack_items
rb .cap
.end:

;
; dictionary
;

; dictionary entry
;
; * want flags first to test flags?
; * want to track call count?
;
; 8  - state & flags (hidden,immediate,inline,noret)
; 8  - key
; 8  - code
; 8  - reserved
; ...

dictionary: 
.entry_size = 32
.latest rq 1
.next rq 1
.start:
.core:
.user rb config.max_user_words * .entry_size
.end:

segment readable executable

entry $
	mov edx, msg_size
	
	lea rsi, [msg]
	mov edi, 1
	mov eax, 1
	syscall

	lea rdi, [code_buffer]
	mov byte [edi], 0xff
	inc rdi
	mov byte [edi], 0xc7
	inc rdi
	mov byte [edi], 0xff
	inc rdi
	mov byte [edi], 0xc7
	inc rdi
	mov byte [edi], 0xff
	inc rdi
	mov byte [edi], 0xc7
	inc rdi
	mov byte [edi], 0xc3
	inc rdi

	xor edi, edi
	;mov edi, [code_buffer.in]
	lea rcx, [code_buffer]
	;add rcx, 2
	call rcx
	mov eax, 60
	syscall


segment readable 

msg db 'blue compiler (fasm edition)',0xA
msg_size = $-msg
