
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

	.syscall_1:
	;; : syscall/1 (( num eax -- result eax )) ... ; inline
	syscall
	
	.exit:
	;; : exit (( status edi  -- )) 60 syscall drop ; noret
	mov eax, 60
	jmp .syscall_1

	.add_1:
	;; : add/1 (( n eax -- n+1 eax )) ... ; inline
	inc eax
	ret 			; how does `ret` work with inline

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
	;; : _start exit ;
	;;
	;; assumes `add1` and `exit` are built in
	;; `6 add1` is run at compile time and results in `7` being on the stack
	;;
	;; the final binary output would roughly be the equivalent of:
	;;
	;; mov eax, 7
	;; mov edi, eax
	;; mov eax, 60
	;; syscall
	;;
	;; * some future peephole optimizer could later reduce the first two lines
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
	
	;; 6 add1 exit 
	mov eax, 6
	call __codebuf.add_1
	
	mov edi, eax
	jmp __codebuf.exit

	;; 
	;; __codebuf.here is set to point to the instructions for _start
	;; then write the instructions to out.bin
	;;

	
	
