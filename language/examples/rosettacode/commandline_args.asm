
global _start

; : syscall ( num:eax -- result:eax | rcx )

__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	jmp __blue_3454868101_0

; : die ( err:eax -- noret )

__blue_3630339793_0:
	neg eax
	mov edi, eax
	jmp __blue_3454868101_0

; : unwrap ( result:eax -- value:eax )

__blue_4055961022_0:
	cmp eax, 0
	jge __blue_2157056155_0
	call __blue_3630339793_0

__blue_2157056155_0:
	ret

; : ordie ( result -- )

__blue_1614081290_0:
	call __blue_4055961022_0
	ret

; : write ( buf:esi len:edx fd:edi -- )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	call __blue_4057121178_0
	jmp __blue_1614081290_0

; : print ( buf len -- )

__blue_372738696_0:
	xor edi, edi
	inc edi
	jmp __blue_3190202204_0

; : newline ( -- )

__blue_4281549323_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 10
db 0
__blue_1223589535_0:
	xor edx, edx
	inc edx
	mov esi, __blue_855163316_0
	jmp __blue_372738696_0

; : println ( buf len -- )

__blue_415234214_0:
	call __blue_372738696_0
	jmp __blue_4281549323_0

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
	jmp __blue_415234214_0

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
	jmp __blue_1911791459_0
