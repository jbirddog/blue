
global _start

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : write ( buf:esi len:edx fd:edi -- result:eax )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	jmp __blue_4057121178_0

; : execve ( filename:edi argv:esi env:edx -- noret )

__blue_172884385_0:
	mov eax, 59
	call __blue_4057121178_0

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : mkdir ( path:edi mode:esi -- result:eax )

__blue_2883839448_0:
	mov eax, 83
	jmp __blue_4057121178_0

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

; : ignore ( result:eax err:edi -- )

__blue_2118064195_0:
	cmp eax, edi
	je __blue_2157056155_1
	call __blue_1614081290_0

__blue_2157056155_1:
	ret

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	jmp __blue_3454868101_0

; : type ( buf len -- )

__blue_1361572173_0:
	xor edi, edi
	inc edi
	call __blue_3190202204_0
	jmp __blue_1614081290_0

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
	je __blue_2157056155_2
	call __blue_1805780446_0

__blue_2157056155_2:
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

; : type-cstr ( buf -- )

__blue_2703255396_0:
	call __blue_3207375596_0
	jmp __blue_1361572173_0

; : type-cstr@ ( addr -- )

__blue_3389152684_0:
	mov rdx, qword [rdx]
	jmp __blue_2703255396_0

; : mkdir ( path -- )

__blue_2883839448_1:
	mov esi, 488
	call __blue_2883839448_0
	mov edi, -17
	jmp __blue_2118064195_0

; : make-build-dirs ( -- )

__blue_2670689297_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 46
db 98
db 117
db 105
db 108
db 100
db 47
db 0
__blue_1223589535_1:
	mov edi, __blue_855163316_1
	call __blue_2883839448_1
	jmp __blue_1223589535_2

__blue_855163316_2:

db 46
db 98
db 117
db 105
db 108
db 100
db 47
db 98
db 105
db 110
db 47
db 0
__blue_1223589535_2:
	mov edi, __blue_855163316_2
	call __blue_2883839448_1
	jmp __blue_1223589535_3

__blue_855163316_3:

db 46
db 98
db 117
db 105
db 108
db 100
db 47
db 111
db 98
db 106
db 47
db 0
__blue_1223589535_3:
	mov edi, __blue_855163316_3
	jmp __blue_2883839448_1

section .bss

; 1 resq cmd-name

__blue_1161787257_0: resq 1
; 1 resq blue-file

__blue_680506038_0: resq 1
section .text

; : usage ( -- noret )

__blue_3461590696_0:
	jmp __blue_1223589535_4

__blue_855163316_4:

db 10
db 9
db 117
db 115
db 97
db 103
db 101
db 58
db 32
db 98
db 97
db 107
db 101
db 32
db 99
db 109
db 100
db 32
db 115
db 111
db 109
db 101
db 102
db 105
db 108
db 101
db 46
db 98
db 108
db 117
db 101
db 10
db 0
__blue_1223589535_4:
	mov edx, 32
	mov esi, __blue_855163316_4
	call __blue_1361572173_0
	jmp __blue_1911791459_0

; : check-argc ( rax -- )

__blue_3569987719_0:
	cmp qword [rax], 3
	je __blue_2157056155_3
	call __blue_3461590696_0

__blue_2157056155_3:
	ret

; : first-arg ( rax -- rax )

__blue_952155568_0:
	add rax, 16
	ret

; : next-arg ( rax -- rax )

__blue_2499737933_0:
	add rax, 8
	ret

; : parse-args ( rax -- )

__blue_4217555750_0:
	call __blue_3569987719_0
	call __blue_952155568_0
	mov [__blue_1161787257_0], rax
	call __blue_2499737933_0
	mov [__blue_680506038_0], rax
	ret

section .bss

; 1 resq execve-file

__blue_3267543346_0: resq 1
; 1 resq execve-argv

__blue_1213363986_0: resq 1
; 1 resq execve-arg1

__blue_55708275_0: resq 1
; 1 resq execve-arg2

__blue_72485894_0: resq 1
; 1 resq execve-envp

__blue_3160449449_0: resq 1
section .text

; : build ( -- noret )

__blue_3281777315_0:
	jmp __blue_1223589535_5

__blue_855163316_5:

db 47
db 117
db 115
db 114
db 47
db 98
db 105
db 110
db 47
db 101
db 110
db 118
db 0
__blue_1223589535_5:
	mov [__blue_3267543346_0], __blue_855163316_5
	jmp __blue_1223589535_6

__blue_855163316_6:

db 98
db 108
db 117
db 101
db 0
__blue_1223589535_6:
	mov [__blue_1213363986_0], __blue_855163316_6
	mov [__blue_55708275_0], __blue_680506038_0
	mov [__blue_72485894_0], 0
	mov [__blue_3160449449_0], 0
	jmp __blue_1911791459_0

; : run ( -- noret )

__blue_718098122_0:
	jmp __blue_1223589535_7

__blue_855163316_7:

db 110
db 101
db 101
db 100
db 32
db 116
db 111
db 32
db 114
db 117
db 110
db 46
db 46
db 46
db 0
__blue_1223589535_7:
	mov edx, 14
	mov esi, __blue_855163316_7
	call __blue_1361572173_0
	call __blue_4281549323_0
	jmp __blue_1911791459_0

; : cmd-table ( -- noret )

__blue_758800390_0:

db 0
db 0
db 0
db 98
db 117
db 105
db 108
db 100
dq __blue_3281777315_0
db 0
db 0
db 0
db 0
db 0
db 114
db 117
db 110
dq __blue_718098122_0
; : cmd-key ( qword:rax len:rcx -- key:rax )

__blue_1785978521_0:
	sub rcx, 8
	neg rcx
	shl rcx, 3
	shl rax, cl
	ret

; : cstr>cmd-key ( cstr:rdx -- key:rax )

__blue_4283867725_0:
	call __blue_3207375596_0
	mov rcx, rdx
	mov rax, qword [rsi]
	jmp __blue_1785978521_0

; : call-cmd ( cmd:rdi -- noret )

__blue_1042682684_0:
	call qword [rdi]

; : call-cmd-with-key ( key:rax -- noret )

__blue_2379826553_0:
	mov rdi, __blue_758800390_0
	mov ecx, 2

; : scan-cmd-table ( tries:ecx tbl:rdi key:rax -- noret )

__blue_612288868_0:
	scasq
	jne __blue_2157056155_4
	call __blue_1042682684_0

__blue_2157056155_4:
	add rdi, 8
	loop __blue_612288868_0
	jmp __blue_3461590696_0

; : call-named-cmd ( name:rdx -- noret )

__blue_2780306156_0:
	mov rdx, qword [rdx]
	call __blue_4283867725_0
	jmp __blue_2379826553_0

; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_4217555750_0
	call __blue_2670689297_0
	mov rdx, [__blue_1161787257_0]
	jmp __blue_2780306156_0
