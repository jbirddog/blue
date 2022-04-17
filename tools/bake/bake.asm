
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

; : execve ( filename:edi argv:esi env:edx -- result:eax )

__blue_172884385_0:
	mov eax, 59
	jmp __blue_4057121178_0

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

;  TODO nicer way to illustrate this

; : build-cmd-key ( -- )

__blue_187718900_0:

db 0
db 0
db 0
db 98
db 117
db 105
db 108
db 100	ret

; : run-cmd-key ( -- )

__blue_18326009_0:

db 0
db 0
db 0
db 0
db 0
db 114
db 117
db 110	ret

; : cmd-key ( buf:rax len:rcx -- key:rax )

__blue_1785978521_0:
	and rcx, 7
	add rcx, -8
	shl rcx, 3
	shr rax, cl
	ret

; : build-cmd ( -- )

__blue_733264130_0:
	jmp __blue_1223589535_5

__blue_855163316_5:

db 110
db 101
db 101
db 100
db 32
db 116
db 111
db 32
db 98
db 117
db 105
db 108
db 100
db 46
db 46
db 46
db 0
__blue_1223589535_5:
	mov edx, 16
	mov esi, __blue_855163316_5
	call __blue_1361572173_0
	jmp __blue_4281549323_0

; : run-cmd ( -- )

__blue_1139689547_0:
	jmp __blue_1223589535_6

__blue_855163316_6:

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
__blue_1223589535_6:
	mov edx, 14
	mov esi, __blue_855163316_6
	call __blue_1361572173_0
	jmp __blue_4281549323_0

;  TODO label/declare vs having to create a new word?

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
dq __blue_733264130_0
db 0
db 0
db 0
db 0
db 0
db 114
db 117
db 110
dq __blue_1139689547_0
; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_4217555750_0
	mov rdx, [__blue_1161787257_0]
	call __blue_3389152684_0
	call __blue_4281549323_0
	mov rdx, [__blue_680506038_0]
	call __blue_3389152684_0
	call __blue_4281549323_0
	call __blue_2670689297_0
	call __blue_733264130_0

;  TODO find cmd from table
	jmp __blue_1911791459_0
