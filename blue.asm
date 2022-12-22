format ELF64 executable 3 ; fasm q: why 3? can omit or change

; needed in asm
;
; * read until c from input buffer
; * create dictionary entry
; * update dictionary entry
; * find dictionary entry
; * call dictionary entry
; * write bytes to code buffer
; * drop/dup/swap

; need design
;
; * call word instructions

segment readable writeable executable

; dictionary entry
;
; * want flags first to test flags?
; * want to track call count?
;
; 1  - flags (hidden,immediate,inline,noret)
; 7  - key
; 8  - pointer to code buffer
; ...

dictionary rb 1024

segment readable executable

main:
	mov edx, msg_size
	
	lea rsi, [msg]
	mov edi, 1
	mov eax, 1
	syscall

	lea rdi, [dictionary]
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
	lea rcx, [dictionary]
	add rcx, 2
	call rcx
	mov eax, 60
	syscall

entry main

segment readable 

msg db 'blue',0xA
msg_size = $-msg
