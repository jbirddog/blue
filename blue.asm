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

segment readable writeable executable

;
; code buffer
;

code_buffer:
.cap = config.word_code_size * config.max_user_words
rb .cap
.next rq 1
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
.entry_size = config.cell_size * 4
.latest rq 1
.next rq 1
.start:
.core:
.user rb config.max_user_words * .entry_size
.end:

segment readable executable

; needed in asm - words to support
;
; * read until c from input buffer
; * create dictionary entry
; * update dictionary entry
; * find dictionary entry
; * call dictionary entry
; * push/pop/drop/dup/swap data stack
; * write bytes to code buffer

compile_byte:
	; works but would like some movsb or something
	mov rdi, [code_buffer.next]
	mov byte [edi], sil
	inc rdi
	mov [code_buffer.next], rdi
	ret
	

entry $
.init_data_structures:
	lea rsi, [code_buffer]
	mov [code_buffer.next], rsi

	mov edx, msg_size
	
	lea rsi, [msg]
	mov edi, 1
	mov eax, 1
	syscall

	; POC - inc edi; ret
	mov sil, 0xff
	call compile_byte
	mov sil, 0xc7
	call compile_byte
	mov sil, 0xc3
	call compile_byte

	xor edi, edi
	lea rcx, [code_buffer]
	add rcx, 2 ; jump over inc edi
	call rcx
	mov eax, 60
	syscall


segment readable 

msg db 'blue compiler (fasm edition)',0xA
msg_size = $-msg
