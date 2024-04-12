
;;;
;;; 
;;; 

	section compiler write exec
	
;;;
;;; 
;;; 

__codebuf:
	.here dq 0
	.start:
	
	.exit:
	;; : exit (( status edi  -- )) 60 syscall ; noret
	mov eax, 60
	syscall

	.user:
	times 4096 db 0

;;;
;;; 
;;; 

__dict:
	.here dq 0
	.start:
	.exit:

	.user:
	times 4096 db 0

;;;
;;; 
;;; 

	global _start

_start:
	mov rax, __codebuf.user	
	mov [__codebuf.here], rax

	mov rax, __dict.user	
	mov [__dict.here], rax
	
	;; 6 add1 exit 
	mov eax, 6
	add eax, 1
	
	mov edi, eax
	jmp __codebuf.exit
	
