format ELF64 executable 3 ; fasm q: why 3? can omit or change

;
; configuration
;

config:

; cell_size isn't really configurable...
.cell_size = 8
.input_buffer_size = 4096
.max_stack_items = 32
.max_user_words = 1024
.word_code_size = 32

;
; code buffer
;

segment readable writeable executable

code_buffer:
;
; when compiling the final output, not sure if it would be 
; better to have another .c_comma for the final buffer, 
; somehow reuse this buffer or have three new statics to 
; track the current buffer target, its start and cap.
;
.next rq 1

.core:
;
; these are the core commands that are compiled in by default
;

.c_comma:
	; assumes al is set
	; should check if there is a byte to write to
	mov rdi, [code_buffer.next]
	stosb
	mov [code_buffer.next], rdi
	ret

;
; space reserved for user defined code
;
.cap = config.word_code_size * config.max_user_words
.user rb .cap
.end:

segment readable executable

.init:
	mov rsi, code_buffer.user
	mov [code_buffer.next], rsi
	ret

;
; compile time stacks
;

segment readable writeable

; need:
;
; * push/pop/drop/dup/swap stacks

data_stack:
.cap = config.cell_size * config.max_stack_items
rb .cap
.end:

return_stack:
.cap = config.cell_size * config.max_stack_items
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
;
; these are the core commands that are compiled in by default
; - once we get bootstrapped refine these
;
.c_comma:
dq 0
db 'c', ',', 0, 0, 0, 0, 0, 0
dq code_buffer.c_comma
dq 0

;
; space reserved for user defined code
;
.cap = config.max_user_words * .entry_size
.user rb .cap
.end:

segment readable executable

.init:
	mov rsi, dictionary.user
	mov [dictionary.next], rsi
	sub rsi, .entry_size
	mov [dictionary.latest], rsi
	ret

segment readable executable

; needed in asm - words to support
;
; * read until c from input buffer
; * create dictionary entry
; * update dictionary entry
; * find dictionary entry
; * call dictionary entry

entry $
	; init data structures:
	call code_buffer.init
	call dictionary.init

	; run tests then re-init data structures?

	mov edx, msg_size

	lea rsi, [msg]
	mov edi, 1
	mov eax, 1
	syscall

	; POC
	mov rcx, dictionary.c_comma
	add rcx, 16

	; inc edi
	mov al, 0xff
	call qword [rcx]
	mov al, 0xc7
	call qword [rcx]
	; ret
	mov al, 0xc3
	call qword [rcx]

	xor edi, edi
	mov rcx, code_buffer.user
	; add rcx, 2 ; jump over inc edi
	call rcx
	mov eax, 60
	syscall


segment readable

msg db 'blue compiler (fasm edition)',0xA
msg_size = $-msg
