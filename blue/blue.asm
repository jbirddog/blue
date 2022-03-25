
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:rdi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

;  : syscall3 ( arg2:rsi arg3:edx arg1:edi num:eax -- result:eax ) syscall ;
;  : write ( buf:rsi len:edx fd:edi -- result:eax ) 1 syscall3 ;
;  : locate ( str:rdi chr:eax -- str:rdi ) scasb repne ;
;  : len ( arg:rsi -- len:rdi ) dup [] 0 locate swap sub ; 
; : len ( arg:rsi -- len:rdi )
__blue_912972556_0:
	mov rcx, -1
	mov rdi, rsi

; : while!0 ( arg:rsi begin:rdi max:rcx -- end:rdi )
__blue_2980471927_0:
	lodsb
	cmp al, 0
	loopne __blue_2980471927_0

; : compute ( begin:rsi end:rdi -- len:rdi )
__blue_1147400058_0:
	sub rsi, rdi
	mov rdi, rsi

; : tmp ( len:rdi -- len:rdi )
__blue_3004525646_0:
	dec rdi
	ret

;  TODO lea
; : argv0 ( rsi -- argv0:rsi )
__blue_834543561_0:
	add rsi, 8
	mov rsi, [rsi]

; : deref ( **char:rsi -- *char:rsi )
__blue_655036747_0:
	ret

;  TODO ideally shouldn't need this
;  : _start ( rsp -- noret ) argv0 5 swap 1 write 0 exit ;
; : _start ( rsp -- noret )
_start:
	mov rsi, rsp
	call __blue_834543561_0
	call __blue_912972556_0
	call __blue_3454868101_0

;  argc [rsp] -> rcx for looping over argv
;  argv lea rsi, [rsp+8], lodsq loop will load each string ptr into rax
;  scan rax til 0 to find length
;  print with length
;  print new line
