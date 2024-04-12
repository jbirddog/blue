
;;;
;;; 
;;; 

	section .dict write

__dict:
.exit:
	
	
;;;
;;; 
;;; 

	section .codebuf write exec

__codebuf:

__builtin:
	.exit:
	; : exit (( status edi  -- )) noret
	mov eax, 60
	db 0x0f, 0x05			; syscall

;;;
;;; 
;;; 

	section .text

	global _start

_start:
	mov eax, 3
	add eax, 4
	mov edi, eax
	call __builtin.exit
	
