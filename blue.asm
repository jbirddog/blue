
;;;
;;; compiler for the Blue Language
;;;

	section compiler write exec

;;;
;;; 
;;;

__codebuf:
	.here dq 0
	
	.start:
	.entry_jmp db 0xE9
	.entry dq 0

	.b_comma:
	;;
	;; : b, (( b al -- )) ... ; inline
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

	.exit:
	;;
	;; : exit (( status edi  -- )) 60 syscall drop ; noret
	;; 
	mov eax, 60
	jmp .syscall_1

	.add1:
	;; 
	;; : add1 (( n eax -- n+1 eax )) ... ; inline
	;; 
	inc eax
	ret

	.__user:
	times 4096 db 0

;;;
;;; 
;;; 

	global _start

_start:	
	mov rsi, __codebuf.__user	
	mov [__codebuf.here], rsi

	;; 
	;; demo of this version of the blue compiler
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
	;; mov rdi, 7
	;; mov eax, 60
	;; syscall
	;;
	;; the output should be a binary file containing the machine code for the
	;; above unoptimized assembly. This should be able to be included in a
	;; asm driver file that can jump to the correct location to execute the
	;; program.
	;;
	;; logic such as parsing the application code and finding entries in the
	;; dictionary will be omitted for the first demo since this is not the
	;; interesting part. the interesting part is providing full access to
	;; all previously defined code at compile time. 
	;;

	;;
	;; compile the user program
	;; 
	
	;; `6 add1` executed at compile time 
	push 6
	pop rax
	call __codebuf.add1

	;; stack now indicates there is an immediate value in `eax`. when moving into
	;; into `edi` for `exit` the value in `eax` needs to be compiled. for now just
	;; move the full register but later respect the size from the register name.

	;; 
	;; compile into __codebuf:
	;; 
	;; BF07000000 - mov rdi, 7
	;;

	push rax 		; don't clobber the `7` in rax
	
	push 0xBF
	pop rax
	call __codebuf.b_comma

	pop rax
	call __codebuf.d_comma

	;; 
	;; E9A6DFFFFF - jmp __codebuf.exit
	;;

	push 0xE9
	pop rax
	call __codebuf.b_comma

	mov rsi, __codebuf.exit
	sub rsi, __codebuf.here
	push rsi
	
	pop rax
	call __codebuf.d_comma

	;; 
	;; set the `entry` to `_start`'s code. for this demo this just happens to be
	;; the start of the user section of the code buffer, but really `entry` would
	;; find the previously defined word and use its code.
	;;
	
	mov rsi, __codebuf.__user
	sub rsi, __codebuf.start
	mov [__codebuf.entry], rsi

	;;
	;; write the code buffer to out.bin and exit
	;;

	;; open
	mov rdi, outfile
	mov esi, 0o1 | 0o100 | 0o1000
	mov edx, 0o640
	mov eax, 2
	syscall

	;; write
	

	;; close
	mov edi, eax
	mov eax, 3
	syscall

	xor edi, edi
	jmp __codebuf.exit

outfile:
	db "out.bin", 0
	.len equ $ - outfile
	
