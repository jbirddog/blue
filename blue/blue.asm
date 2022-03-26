
global _start

; : syscall ( num:rax -- result:rax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:rdi -- noret )
__blue_3454868101_0:
	mov rax, 60
	call __blue_4057121178_0

; : syscall3 ( arg2:rsi arg3:rdx arg1:edi num:rax -- result:eax )
__blue_1472650507_0:
	call __blue_4057121178_0
	ret

; : write ( buf:rsi len:rdx fd:edi -- result:rax )
__blue_3190202204_0:
	mov rax, 1
	call __blue_1472650507_0
	ret

;  TODO unwrap
;  TODO this is an example of invalid stack handling due to lodsb/loopne
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
;  TODO ideally shouldn't need these empty words
; : argv ( rbp -- rbp )
__blue_2584388227_0:
	ret

; : next-arg ( argv:rbp -- arg:rdx )
__blue_2499737933_0:
	add rbp, 8
	mov rdx, [rbp]

; : deref ( rdx -- rdx )
__blue_655036747_0:
	ret

;  need to next-arg dup len writeln
; : _start ( rsp -- noret )
_start:
	mov rbp, rsp
	call __blue_2584388227_0
	call __blue_2499737933_0
	mov rsi, rdx
	call __blue_1488600471_0
	xchg rdx, rsi
	mov edi, 1
	call __blue_3190202204_0
	mov rdi, rax
	call __blue_3454868101_0

;  argc [rsp] -> rcx for looping over argv
;  argv lea rsi, [rsp+8], lodsq loop will load each string ptr into rax
;  scan rax til 0 to find length
;  print with length
;  print new line