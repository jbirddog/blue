
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:rdi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : locate ( str:rdi chr:eax -- str:rdi )
__blue_1524600127_0:
	repne scasb
	ret

; : len ( arg:rsi -- len:rdi )
__blue_912972556_0:
	mov eax, 0
	mov rdi, rsi
	call __blue_1524600127_0
	sub rdi, rsi
	ret

; : argv0 ( rsi -- argv0:rsi )
__blue_834543561_0:
	add rsi, 8
	ret

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