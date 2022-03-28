
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : syscall3 ( arg2:esi arg3:edx arg1:edi num:eax -- result:eax )
__blue_1472650507_0:
	call __blue_4057121178_0
	ret

; : write ( buf:esi len:edx fd:edi -- result:eax )
__blue_3190202204_0:
	mov eax, 1
	call __blue_1472650507_0
	ret

;  TODO unwrap
;  TODO writeln
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

;  1 resq argc
;  1 resq argv
;  : argc! ( rsp -- ) argc ! ;
;  : argv! ( rbp -- ) 8 add argv ! ;
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
	mov edi, eax
	call __blue_3454868101_0

;  argc [rsp] -> rcx for looping over argv
;  argv lea rsi, [rsp+8], lodsq loop will load each string ptr into rax
;  scan rax til 0 to find length
;  print with length
;  print new line