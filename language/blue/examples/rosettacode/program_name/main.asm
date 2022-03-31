
global _start

; : syscall ( num:eax -- result:eax )
__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )
__blue_3454868101_1:
	mov eax, 60
	call __blue_4057121178_0

; : exit.ok ( -- noret )
__blue_3274522691_0:
	mov edi, 0
	call __blue_3454868101_1

; : syscall ( arg2:esi arg3:edx arg1:edi num:eax -- result:eax )
__blue_4057121178_1:
	call __blue_4057121178_0
	ret

; : write ( buf len -- )
__blue_3190202204_1:
	mov eax, 1
	mov edi, 1
	call __blue_4057121178_1
	ret

; : lf ( -- )
__blue_1261555351_0:

db 10
; : newline ( -- )
__blue_4281549323_0:
	mov edx, 1
	mov esi, __blue_1261555351_0
	call __blue_3190202204_1
	ret

; : writeln ( buf len -- )
__blue_840226778_0:
	call __blue_3190202204_1
	call __blue_4281549323_0
	ret

; : find0 ( start:rsi -- end:rsi )
__blue_1805780446_0:
	lodsb
	cmp al, 0
	je __blue_2157056155_0
	call __blue_1805780446_0

__blue_2157056155_0:
	ret

; : cstrlen ( str:rdi -- len:rsi )
__blue_1939608060_0:
	mov rsi, rdi
	call __blue_1805780446_0
	sub rsi, rdi
	dec rsi
	ret

; : cstr>str ( cstr:rdx -- str:rsi len:rdx )
__blue_3207375596_0:
	mov rdi, rdx
	call __blue_1939608060_0
	xchg rdx, rsi
	ret

; : print-arg ( arg -- )
__blue_2701174125_0:
	call __blue_3207375596_0
	call __blue_840226778_0
	ret

; : arg0 ( rsp -- rsp )
__blue_1611286325_0:
	add rsp, 8
	ret

; : _start ( rsp -- noret )
_start:
	add rsp, 8
	mov rdx, [rsp]
	call __blue_2701174125_0
	call __blue_3274522691_0
