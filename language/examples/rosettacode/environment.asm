
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

; : type ( buf len -- )

__blue_1361572173_0:
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
	jmp __blue_1361572173_0

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
	jmp __blue_4281549323_0

; : bob ( -- )

__blue_2261164244_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 98
db 111
db 98
db 0
__blue_1223589535_1:
	mov edx, 3
	mov esi, __blue_855163316_1
	call __blue_1361572173_0
	jmp __blue_4281549323_0

section .bss

; 1 resq envp

__blue_2355496332_0: resq 1
section .text

; : store-envp ( rax -- )

__blue_2164669320_0:
	add rax, 32
	mov [__blue_2355496332_0], rax
	ret

; : getenv ( name:rsi len:rcx -- value:rdi )

__blue_1306389850_0:
	mov rax, [__blue_2355496332_0]

; : scan-envp ( max:rcx name:rsi next:rax -- value:rdi )

__blue_491392598_0:
	mov rdi, qword [rax]

; : check-entry ( max:rcx name:rsi entry:rdi -- value:rdi )

__blue_585535462_0:
	repe cmpsb

;  drop drop print bye
	mov edi, ecx
	jmp __blue_3454868101_0

;  dec 61 cmp ' bob xe

;  drop drop print bye
	ret

; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_2164669320_0
	jmp __blue_1223589535_2

__blue_855163316_2:

db 83
db 69
db 83
db 83
db 73
db 79
db 78
db 95
db 77
db 65
db 78
db 65
db 71
db 69
db 82
db 0
__blue_1223589535_2:
	mov rcx, 15
	mov rsi, __blue_855163316_2
	call __blue_1306389850_0
	jmp __blue_1911791459_0

;  envp @ print bye ;

;  0 envp @ 

;  : print-env ( max:rcx env:rsp -- noret ) 

; 	dup @ print-env-var 8 add @ 0 cmp latest loopne 

; 	bye 

;  ;
