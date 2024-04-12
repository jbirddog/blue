
;;;
;;; 
;;; 

	section codebuf write exec
	
;;;
;;; 
;;; 

__codebuf:
	.here dq 0
	.start:
	.exit:
	;; : exit (( status edi  -- )) 60 syscall ; noret
	mov eax, 60
	db 0x0f, 0x05			; syscall

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
	
	;; 3 4 add exit 
	mov eax, 3
	add eax, 4
	
	mov edi, eax
	jmp __codebuf.exit
	
