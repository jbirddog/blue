
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : exit.ok ( -- noret )
__blue_3274522691_0:
	mov edi, 0
	call __blue_3454868101_0

; : exit.syserr ( err:eax -- noret )
__blue_1490145965_0:
	neg eax
	mov edi, eax
	call __blue_3454868101_0

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_1490145965_0

__blue_2157056155_0:
	ret

; : syscall3 ( arg2:esi arg3:edx arg1:edi num:eax -- result:eax )
__blue_1472650507_0:
	call __blue_4057121178_0
	ret

; : write ( buf len -- result )
__blue_3190202204_0:
	mov eax, 1
	mov edi, 1
	call __blue_1472650507_0
	ret

; : write! ( buf len -- wrote )
__blue_3553432007_0:
	call __blue_3190202204_0
	call __blue_4055961022_0
	ret

; : lf ( -- )
__blue_1261555351_0:

db 10
; : lf ( -- wrote )
__blue_1261555351_1:
	mov edx, 1
	mov esi, __blue_1261555351_0
	call __blue_3553432007_0
	ret

; : writeln! ( buf len -- x x )
__blue_3520069665_0:
	call __blue_3190202204_0
	call __blue_1261555351_1
	ret

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
; : next-arg ( argv:rbp -- arg:rdx )
__blue_2499737933_0:
	add rbp, 8
	mov rdx, [rbp]

; : _ ( rdx -- rdx )
__blue_3658226030_0:
	ret

;  TODO ideally shouldn't need
section .bss

; 1 resq argc
__blue_2366279180_0: resq 1
; 1 resq argv
__blue_2584388227_0: resq 1
section .text

; : argc! ( rsp -- )
__blue_882757847_0:
	mov [__blue_2366279180_0], rsp
	ret

; : argv! ( rbp -- )
__blue_549324038_0:
	add rbp, 8
	mov [__blue_2584388227_0], rbp
	ret

;  need to next-arg dup len writeln
; : _start ( rsp -- noret )
_start:
	mov rbp, rsp
	call __blue_2499737933_0
	mov rsi, rdx
	call __blue_1488600471_0
	xchg rdx, rsi
	call __blue_3520069665_0
	call __blue_3274522691_0
