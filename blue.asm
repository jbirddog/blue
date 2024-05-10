
;;;
;;; compiler for the Blue Language
;;;

	section compiler write exec

	global _start


mode:
	.interpret equ 0
	.compile equ 1

	db .interpret


;;;
;;; dictionary
;;;

dict:
	.codebuf_offset equ 16
	
	.here dq 0
	.start:

	.__core:

	.b_comma:
	dq 0
	db 'b', ',', 0, 0, 0, 0, 0, 0
	dq codebuf.b_comma
	dq 0

	.d_comma:
	dq 0
	db 'd', ',', 0, 0, 0, 0, 0, 0
	dq codebuf.d_comma
	dq 0
	
	.__user:
	
	.add1:
	dq 0
	db 'a', 'd', 'd', '1', 0, 0, 0, 0
	dq codebuf.add1
	dq 0

	times 4096 db 0
	
;;;
;;; code buffer 
;;;

codebuf:
	.here dq 0

	.__core:
	
	.start:
	db 0xE9
	.entry dq 0

	.b_comma:
	;;
	;; : b, (( b al -- )) ... ; immed
	;; 
	mov rdi, [.here]
	stosb
	mov [.here], rdi
	ret

	.d_comma:
	;;
	;; : d, (( d eax -- )) ... ; inline
	;; 
	mov rdi, [.here]
	stosd
	mov [.here], rdi
	ret

	.syscall_1:
	;;
	;; : syscall/1 (( num eax -- result eax )) ... ; inline
	;; 
	syscall
	ret

	.exit:
	;;
	;; : exit (( status edi  -- )) 60 syscall/1 drop ; noret
	;; 
	mov eax, 60
	syscall

	.add1:
	;; 
	;; : add1 (( n eax -- n+1 eax )) ... ; inline
	;; 
	inc eax
	ret

	.__user:
	times 4096 db 0

;;;
;;; helpers
;;; 

interpret:
	mov rsi, [codebuf.here]
	mov [dict.here + dict.codebuf_offset], rsi

	mov byte [mode], mode.interpret
	ret

interpretive_dance:
	push 0xC3		; ret
	pop rax
	call codebuf.b_comma

	call [dict.here + dict.codebuf_offset]

	ret

compile:
	call interpretive_dance
	
	mov rsi, [dict.here + dict.codebuf_offset]
	mov [codebuf.here], rsi
	
	mov byte [mode], mode.compile
	ret

init:
	mov rsi, codebuf.__user
	mov [codebuf.here], rsi

	mov rsi, dict.__user
	mov [dict.here], rsi

	call interpret
	ret


;;;
;;; compiler entry point
;;; 

_start:
	call init
	
	;; 
	;; want to simulate the program:
	;;
	;; 6 add1
	;; : _start exit ; entry
	;;
	;; demo assumes `add1` and `exit` are already defined
	;; `6 add1` is run at compile time and results in `7` being on the stack
	;;
	;;
	;; the final binary output would roughly be the equivalent of:
	;;
	;; jmp [location of `entry`]
	;; .... codebuf
	;; mov rdi, 7
	;; jmp [location of codebuf.exit]
	;;
	;; the output should be a binary file containing the machine code for the
	;; above unoptimized assembly. This should be able to be included in a
	;; asm driver file that jumps to the correct location to execute the
	;; program.
	;;
	;; logic such as parsing the application code and finding entries in the
	;; dictionary will be omitted for the first demo since this is not the
	;; interesting part. the interesting part is providing full access to
	;; all previously defined code at compile time. 
	;;
	
	;; `6 add1` executed at compile time
	
	push 0x6A		; push
	pop rax
	call codebuf.b_comma

	push 0x06		; 6
	pop rax
	call codebuf.b_comma

	push 0x58		; pop rax
	pop rax
	call codebuf.b_comma

	push 0xE8		; call
	pop rax
	call codebuf.b_comma

	mov rax, [dict.add1 + dict.codebuf_offset]
	sub rax, [codebuf.here]
	sub rax, 4

	call codebuf.d_comma
	
	call compile
	
	;; stack now indicates there is an immediate value in `eax`. when moving into
	;; into `edi` for `exit` the value in `eax` needs to be compiled. for now just
	;; move the full register but later respect the size from the register name.

	;; 
	;; compile into codebuf:
	;; 
	;; BF07000000 - mov rdi, 7
	;;

	push rax 		; don't clobber the `7` in rax
	
	push 0xBF
	pop rax
	call codebuf.b_comma

	pop rax
	call codebuf.d_comma
	
	;; 
	;; E9XXXXXXXX - jmp codebuf.exit
	;;

	push 0xE9
	pop rax
	call codebuf.b_comma

	mov rsi, codebuf.exit
	sub rsi, [codebuf.here]
	sub rsi, 4
	push rsi
	
	pop rax
	call codebuf.d_comma

	;; 
	;; set the `entry` to `_start`'s code. for this demo this just happens to be
	;; the start of the user section of the code buffer, but really `entry` would
	;; find the previously defined word and use its code. like finding a word in
	;; the dictionary, this does not impact the correctness of the demo.
	;;
	
	mov rsi, codebuf.__user
	sub rsi, codebuf.start
	sub rsi, 5
	mov [codebuf.entry], rsi

	;;
	;; write the code buffer to out.bin and exit
	;;

	;; open
	mov rdi, outfile
	mov esi, 0o1 | 0o100 | 0o1000
	mov edx, 0o640
	mov eax, 2
	syscall

	push rax
	push rax

	;; write
	pop rdi
	mov rsi, codebuf.start
	mov rdx, [codebuf.here]
	sub rdx, codebuf.start
	mov eax, 1
	syscall
	

	;; close
	pop rdi
	mov eax, 3
	syscall

	xor edi, edi
	jmp codebuf.exit

outfile:
	db "out.bin", 0
	.len equ $ - outfile
	
