
global _start

; : syscall ( num:eax -- result:eax | rcx )
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

; : exit.syserr ( err:eax -- noret )
__blue_1490145965_0:
	neg eax
	mov edi, eax
	call __blue_3454868101_1

; : unwrap ( result:eax -- value:eax )
__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_1490145965_0

__blue_2157056155_0:
	ret

; : ordie ( result -- )
__blue_1614081290_0:
	call __blue_4055961022_0
	ret

; : syscall ( arg2:esi arg3:edx arg1:edi num:eax -- result:eax )
__blue_4057121178_1:
	call __blue_4057121178_0
	ret

; : write ( buf len -- )
__blue_3190202204_1:
	mov eax, 1
	mov edi, 1
	call __blue_4057121178_1
	call __blue_1614081290_0
	ret

; : newline ( -- )
__blue_4281549323_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 10
db 0
__blue_1223589535_0:
	mov edx, 1
	mov esi, __blue_855163316_0
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
	je __blue_2157056155_1
	call __blue_1805780446_0

__blue_2157056155_1:
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

; : _start ( rsp -- noret )
_start:
	mov rcx, [rsp]

; : print-args ( argc:rcx argv:rsp -- noret )
__blue_2449731130_0:
	add rsp, 8
	mov rdx, [rsp]
	push rcx
	call __blue_2701174125_0
	pop rcx
	loop __blue_2449731130_0
	call __blue_3274522691_0
