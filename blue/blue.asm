
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
;  TODO this is hacky
; : find0 ( start:rsi max:rcx -- end:rsi )
__blue_1805780446_0:
	lodsb
	cmp al, 0
	loopne __blue_1805780446_0
	ret

; : range-len ( start:rdi end:rsi -- len:rsi )
__blue_3477417540_0:
	sub rsi, rdi
	dec rsi
	ret

; : cstr-range ( start:rdi -- begin:rdi end:rsi )
__blue_2411088989_0:
	mov rcx, -1
	mov rsi, rdi
	call __blue_1805780446_0
	ret

; : strlen ( str:rsi -- len:rsi )
__blue_1488600471_0:
	mov rdi, rsi
	call __blue_2411088989_0
	call __blue_3477417540_0
	ret

;  TODO lea
; : next-arg ( rsp -- argv:rsi )
__blue_2499737933_0:
	add rsp, 8
	mov rsi, [rsp]

; : deref ( rsi -- rsi )
__blue_655036747_0:
	ret

;  TODO ideally shouldn't need this
;  need to next-arg dup len writeln
;  
; : _start ( rsp -- noret )
_start:
	call __blue_2499737933_0
	call __blue_1488600471_0
	mov rdi, rsi
	call __blue_3454868101_0

;  argc [rsp] -> rcx for looping over argv
;  argv lea rsi, [rsp+8], lodsq loop will load each string ptr into rax
;  scan rax til 0 to find length
;  print with length
;  print new line