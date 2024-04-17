
;;;
;;; compiler for the Blue Language
;;;

	section compiler write exec

;;;
;;; 
;;;

__stack:
	.here dq 0
	.start times 32 dq 0
	.end:

	.push:
	;; assumes value in rax
	mov rsi, [.here]
	stosq
	mov [.here], rsi
	ret

__codebuf:
	.here dq 0
	
	.start:
	.entry_jmp db 0xE9
	.entry dq 0

	.syscall_1:
	;; : syscall/1 (( num eax -- result eax )) ... ; inline
	syscall
	
	.exit:
	;; : exit (( status edi  -- )) 60 syscall drop ; noret
	mov eax, 60
	jmp .syscall_1

	.add1:
	;; : add1 (( n eax -- n+1 eax )) ... ; inline
	inc eax
	ret

	.__user:
	times 4096 db 0

;;;
;;; 
;;; 

__dict:
	.here dq 0
	.start:
	.exit:

	.__user:
	times 4096 db 0

;;;
;;; 
;;; 

	global _start

_start:
	mov rsi, __stack.start
	mov [__stack.here], rsi
	
	mov rsi, __codebuf.__user	
	mov [__codebuf.here], rsi

	mov rsi, __dict.__user	
	mov [__dict.here], rsi

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
	;; into `edi` for `exit` the value of `eax` needs to be compiled. for now just
	;; move the full register but later respect the size from the register name.

	;; 
	;; TODO: compile into __codebuf:
	;; 
	;; BF07000000 - mov rdi, 7
	;; E9A6DFFFFF - jmp __codebuf.exit
	;; 

	;; 
	;; set the `entry` to `_start`'s code. for this demo this just happens to be
	;; the start of the user section of the code buffer, but really `entry` would
	;; find the previously defined word and use its code.
	;;

	;;
	;; write the code buffer to out.bin and exit
	;; 

	xor edi, edi
	jmp __codebuf.exit
