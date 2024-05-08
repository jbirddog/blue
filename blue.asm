
;;;
;;; compiler for the Blue Language
;;;

	section compiler write exec

	global _start

;;;
;;; constants
;;; 

location:
	.stack equ 0
	.register equ 1

mode:
	.interpret equ 0
	.compile equ 1

registers:
	.rax equ 0

size:
	.b equ 1
	.w equ 2
	.d equ 4
	.q equ 8

;;;
;;; dictionary
;;;

__dict:
	.here dq 0
	.start:

	.b_comma:
	dq 0
	db 'b', ',', 0, 0, 0, 0, 0, 0
	dq __codebuf.b_comma
	dq 0

	.d_comma:
	dq 0
	db 'd', ',', 0, 0, 0, 0, 0, 0
	dq __codebuf.d_comma
	dq 0
	
	.add1:
	dq 0
	dq 'a', 'd', 'd', '1', 0, 0, 0, 0
	dq __codebuf.add1
	dq 0

	.__user:
	times 4096 db 0
	
;;;
;;; code buffer 
;;;

__codebuf:
	.here dq 0
	
	.start:
	db 0xE9
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
;;; compiler
;;; 

blue:
	.mode db mode.interpret

	.init:
	mov rsi, __codebuf.__user
	mov [__codebuf.here], rsi

	mov rsi, __dict.__user
	mov [__dict.here], rsi
	
	ret


;;;
;;; compiler entry point
;;; 

_start:
	call blue.init
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
	;; jmp [location of user code]
	;; .... __codebuf
	;; mov rdi, 7
	;; jmp [location of __codebuf.exit]
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

	;;
	;; compile the user program
	;; 
	
	;; `6 add1` executed at compile time 
	push 6
	pop rax
	call __codebuf.add1

	;;
	;; demo 2 - the above code simulated the fact that a `6` was parsed, not found
	;; in the dictionary and pushed as a literal value at compile time. The value
	;; from the stack is then moved into rax due to `add1`'s stack effect. The
	;; location of `add1`'s code is then found via the dictionary and called.
	;;
	;; for demo 2 we are going to pretend `6` was already parsed, not found as a
	;; word and is about to be pushed. when the word is pushed we need to add an
	;; entry to the compile time stack that says: "interpret & literal". this will
	;; be required for the second part of the demo, handling a simple move of a
	;; literal from the stack to `rax`. this requires knowledge of `add1`'s stack
	;; effect. once that is done we can change the call of `__codebuf.add1` to
	;; be a relative location, as if it was found in the dictionary.
	;;
	;; to allow interpreted code and immediate words to all operate the same, when
	;; a word is finished compiling via `;`, the codebuf location for `here` of the
	;; dictionary will be set to codebuf's `here`. This will serve as a scratchpad
	;; for interpreted code that will be overwritten once a new word is compiled.
	;; interpreted code will be compiled into this space just like the body of any
	;; word. the start of compilation for a word `:` will first compile in a `ret`
	;; and call the codebuf location of `here`. once that returns `here` pointers
	;; need to be reset and the word can be compiled.
	;;
	;; needed:
	;; 
	;; [X] mode constants (interpret, compile)
	;; [X] size constants (b, w, d, q)
	;; [X] location constants (stack, register, memory)
	;; [X] knowledge of interpret vs compile mode
	;; [X] start in interpret mode
	;; [X] init dictionary like codebuf
	;; [ ] compile time stack definition (mode, location, size)
	;; [ ] compile time dictionary definition (headers, codebuf location, etc)
	;; [ ] code to enter interpret mode
	;; [ ] code to enter compile mode
	;; [ ] tmp call to enter interpret mode
	;; [X] hardcoded dictionary entry for `b,`, `c,`, `add1`
	;; [ ] operations to use rax, etc constants (pop rax)
	;; [ ] call to __codebuf.add1 via offset
	;;
	;;
	;; questions:
	;;
	;;   - how are stack effects stored? in the dictionary directly? pointer
	;;     to another structure? directly means variable length dictionary
	;;     headers and a previous pointer...
	;; 
	;; demo 3 could be handling of the output stack effect?
	;; 

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
	;; E9XXXXXXXX - jmp __codebuf.exit
	;;

	push 0xE9
	pop rax
	call __codebuf.b_comma

	mov rsi, __codebuf.exit
	sub rsi, [__codebuf.here]
	sub rsi, 4
	push rsi
	
	pop rax
	call __codebuf.d_comma

	;; 
	;; set the `entry` to `_start`'s code. for this demo this just happens to be
	;; the start of the user section of the code buffer, but really `entry` would
	;; find the previously defined word and use its code. like finding a word in
	;; the dictionary, this does not impact the correctness of the demo.
	;;
	
	mov rsi, __codebuf.__user
	sub rsi, __codebuf.start
	sub rsi, 5
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

	push rax
	push rax

	;; write
	pop rdi
	mov rsi, __codebuf.start
	mov rdx, [__codebuf.here]
	sub rdx, __codebuf.start
	mov eax, 1
	syscall
	

	;; close
	pop rdi
	mov eax, 3
	syscall

	xor edi, edi
	jmp __codebuf.exit

outfile:
	db "out.bin", 0
	.len equ $ - outfile
	
