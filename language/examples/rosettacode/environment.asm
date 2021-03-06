
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
	call __blue_1614081290_0
	ret

; : type ( buf len -- )

__blue_1361572173_0:
	xor edi, edi
	inc edi
	call __blue_3190202204_0
	ret

; : newline ( -- )

__blue_4281549323_0:
	jmp __blue_1223589535_0

__blue_855163316_0:

db 10,0
__blue_1223589535_0:
	xor edx, edx
	inc edx
	mov esi, __blue_855163316_0
	call __blue_1361572173_0
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

; : print ( var -- )

__blue_372738696_0:
	call __blue_3207375596_0
	call __blue_1361572173_0
	call __blue_4281549323_0
	ret

; : bob ( -- )

__blue_2261164244_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 98,111,98,0
__blue_1223589535_1:
	mov edx, 3
	mov esi, __blue_855163316_1
	call __blue_1361572173_0
	call __blue_4281549323_0
	ret

section .bss

; 1 resq envp

__blue_2355496332_0: resq 1
; 1 resq envp-entry

__blue_2301798669_0: resq 1
section .text

; : store-envp ( rax -- )

__blue_2164669320_0:
	add rax, 24
	mov qword [__blue_2355496332_0], rax
	ret

; : set-envp-entry ( rax -- )

__blue_651937478_0:
	mov qword [__blue_2301798669_0], rax
	ret

; : reset-envp-entry ( -- )

__blue_3243367623_0:
	mov rax, [__blue_2355496332_0]
	call __blue_651937478_0
	ret

; : advance ( rax -- rax )

__blue_667710333_0:
	add rax, 8
	ret

; : advance-envp-entry ( -- )

__blue_4288035396_0:
	mov rax, [__blue_2301798669_0]
	call __blue_667710333_0
	call __blue_651937478_0
	ret

;  TODO need @@ to avoid this double decl

; : value-for-name? ( namelen:rcx name:rsi entry:rdx -- value:rdi unmatched:rcx )

__blue_625331137_0:
	mov rdi, qword [rdx]

; : 'value-for-name? ( namelen:rcx name:rsi entry:rdi -- value:rdi unmatched:rcx )

__blue_1436770364_0:

;  TODO this will match short, like HO will match E=value for HOME=value
	repe cmpsb
	inc dil
	ret

; : getenv ( name:r8 len:r9 -- value:rdi )

__blue_1306389850_0:
	call __blue_3243367623_0

; : check-entry ( len:r9 name:r8 -- value:rdi )

__blue_585535462_0:
	mov rdx, [__blue_2301798669_0]
	mov rsi, r8
	mov rcx, r9
	call __blue_625331137_0
	cmp rcx, 0
	je __blue_2157056155_2
	call __blue_4288035396_0

__blue_2157056155_2:
	je __blue_2157056155_3
	call __blue_585535462_0

__blue_2157056155_3:
	ret

; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_2164669320_0
	jmp __blue_1223589535_2

__blue_855163316_2:

db 72,79,77,69,0
__blue_1223589535_2:
	mov r9, 4
	mov r8, __blue_855163316_2
	call __blue_1306389850_0
	mov rdx, rdi
	call __blue_372738696_0
	jmp __blue_1223589535_3

__blue_855163316_3:

db 80,65,84,72,0
__blue_1223589535_3:
	mov r9, 4
	mov r8, __blue_855163316_3
	call __blue_1306389850_0
	mov rdx, rdi
	call __blue_372738696_0
	jmp __blue_1223589535_4

__blue_855163316_4:

db 83,69,83,83,73,79,78,95,77,65,78,65,71,69,82,0
__blue_1223589535_4:
	mov r9, 15
	mov r8, __blue_855163316_4
	call __blue_1306389850_0
	mov rdx, rdi
	call __blue_372738696_0
	jmp __blue_1223589535_5

__blue_855163316_5:

db 83,72,69,76,76,0
__blue_1223589535_5:
	mov r9, 5
	mov r8, __blue_855163316_5
	call __blue_1306389850_0
	mov rdx, rdi
	call __blue_372738696_0
	jmp __blue_1911791459_0
