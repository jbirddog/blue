
global _start

; : syscall ( num:eax -- result:eax )

__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

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

; : fork ( -- result:eax )

__blue_1046004769_0:
	mov eax, 57
	call __blue_4057121178_0
	jmp __blue_4055961022_0

; : execve ( filename:rdi argv:rsi env:rdx -- noret )

__blue_172884385_0:
	mov eax, 59
	call __blue_4057121178_0
	call __blue_1614081290_0

section .bss

; 1 resd wait-status

__blue_285992641_0: resd 1
section .text

; : wait4 ( pid:edi status:rsi options:rdx usage:r10 -- result:eax )

__blue_2279771388_0:
	mov eax, 61
	jmp __blue_4057121178_0

;  TODO want to return wait-status @ but outputs don't flow yet

;  TODO actually need ports of WIFEXITED and WEXITSTATUS

; : waitpid ( pid:edi -- )

__blue_3964545837_0:
	xor r10, r10
	xor rdx, rdx
	mov rsi, __blue_285992641_0
	call __blue_2279771388_0
	jmp __blue_1614081290_0

; : write ( buf:esi len:edx fd:edi -- result:eax )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	jmp __blue_4057121178_0

; : mkdir ( path:edi mode:esi -- result:eax )

__blue_2883839448_0:
	mov eax, 83
	jmp __blue_4057121178_0

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

;  TODO this is an example of needing indirect clobber detection

; : cstr>str ( cstr:rdx -- str:rsi len:rdx | rdi )

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

; : build-dir ( -- )

__blue_1221549521_0:
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
	ret

; : bin-dir ( -- )

__blue_1480828760_0:
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
	ret

;  TODO compile time concat

; : obj-dir ( -- )

__blue_264527620_0:
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
	ret

; : make-build-dirs ( -- )

__blue_2670689297_0:
	jmp __blue_1223589535_4

__blue_855163316_4:

db 46
db 98
db 117
db 105
db 108
db 100
db 47
db 0
__blue_1223589535_4:
	mov edi, __blue_855163316_4
	call __blue_2883839448_1
	jmp __blue_1223589535_5

__blue_855163316_5:

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
__blue_1223589535_5:
	mov edi, __blue_855163316_5
	call __blue_2883839448_1
	jmp __blue_1223589535_6

__blue_855163316_6:

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
__blue_1223589535_6:
	mov edi, __blue_855163316_6
	jmp __blue_2883839448_1

section .bss

; 1 resq cmd-name

__blue_1161787257_0: resq 1
; 1 resq blue-file

__blue_680506038_0: resq 1
; 1 resq envp

__blue_2355496332_0: resq 1
;  TODO these are needed because we can't currently `@ var !` and retain operation size

section .text

; : cmd-name! ( rcx -- )

__blue_1525211016_0:
	mov qword [__blue_1161787257_0], rcx
	ret

; : blue-file! ( rcx -- )

__blue_1899373493_0:
	mov qword [__blue_680506038_0], rcx
	ret

; : usage ( -- noret )

__blue_3461590696_0:
	jmp __blue_1223589535_7

__blue_855163316_7:

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
__blue_1223589535_7:
	mov edx, 32
	mov esi, __blue_855163316_7
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

; : environment ( rax -- rax )

__blue_1072573434_0:
	add rax, 24
	ret

; : parse-args ( rax -- )

__blue_4217555750_0:
	call __blue_3569987719_0
	call __blue_952155568_0
	mov rcx, qword [rax]
	call __blue_1525211016_0
	jmp __blue_1223589535_8

__blue_855163316_8:

db 98
db 97
db 107
db 101
db 46
db 98
db 108
db 117
db 101
db 0
__blue_1223589535_8:
	mov rcx, __blue_855163316_8
	call __blue_1899373493_0

;  TODO second-arg is not right
	call __blue_1072573434_0
	mov qword [__blue_2355496332_0], rax
	ret

section .bss

; 512 resb base-file

__blue_3277841025_0: resb 512
; 512 resb assembly-file

__blue_565080558_0: resb 512
; 512 resb object-file

__blue_496119923_0: resb 512
; 512 resb binary-file

__blue_837047421_0: resb 512
;  TODO swap drop -> nip

section .text

; : copy-str ( src:rsi len:rcx dest:rdi -- tail:rdi )

__blue_2360258130_0:
	rep movsb
	ret

; : copy-cstr ( src:rsi dest:rdi -- tail:rdi )

__blue_2435236535_0:
	mov rdx, rsi
	push rdi
	call __blue_3207375596_0
	pop rdi
	mov rcx, rdx
	jmp __blue_2360258130_0

;  TODO swap rot -> -rot

; : append-str ( tail:rdi src:rsi len:rcx -- tail:rdi )

__blue_256417459_0:
	rep movsb
	ret

; : append-cstr ( tail:rdi src:rsi -- tail:rdi )

__blue_586198672_0:
	mov rdx, rsi
	push rdi
	call __blue_3207375596_0
	pop rdi
	mov rcx, rdx
	jmp __blue_256417459_0

;  TODO should drop .blue explicitly vs taking 5 off the length...

; : build-base-file-name ( -- )

__blue_914170956_0:
	mov rdx, [__blue_680506038_0]
	call __blue_3207375596_0
	sub rdx, 5
	mov rdi, __blue_3277841025_0
	mov rcx, rdx
	jmp __blue_2360258130_0

; : build-assembly-file-name ( -- )

__blue_976802625_0:
	mov rdi, __blue_565080558_0
	mov rsi, __blue_3277841025_0
	call __blue_2435236535_0
	jmp __blue_1223589535_9

__blue_855163316_9:

db 46
db 97
db 115
db 109
db 0
__blue_1223589535_9:
	mov rcx, 4
	mov rsi, __blue_855163316_9
	jmp __blue_256417459_0

; : build-object-file-name ( -- )

__blue_3419772654_0:
	jmp __blue_1223589535_10

__blue_855163316_10:

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
__blue_1223589535_10:
	mov rdi, __blue_496119923_0
	mov rsi, __blue_855163316_10
	call __blue_2435236535_0
	mov rsi, __blue_3277841025_0
	call __blue_586198672_0
	jmp __blue_1223589535_11

__blue_855163316_11:

db 46
db 111
db 0
__blue_1223589535_11:
	mov rcx, 2
	mov rsi, __blue_855163316_11
	jmp __blue_256417459_0

; : build-binary-file-name ( -- )

__blue_1696784928_0:
	jmp __blue_1223589535_12

__blue_855163316_12:

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
__blue_1223589535_12:
	mov rdi, __blue_837047421_0
	mov rsi, __blue_855163316_12
	call __blue_2435236535_0
	mov rsi, __blue_3277841025_0
	jmp __blue_586198672_0

; : build-output-file-names ( -- )

__blue_747073145_0:
	call __blue_914170956_0
	call __blue_976802625_0
	call __blue_3419772654_0
	jmp __blue_1696784928_0

section .bss

; 1 resq env-file

__blue_2063802741_0: resq 1
; 1 resq env-arg0

__blue_188583195_0: resq 1
; 1 resq execve-file

__blue_3267543346_0: resq 1
; 1 resq execve-arg0

__blue_38930656_0: resq 1
; 1 resq execve-arg1

__blue_55708275_0: resq 1
; 1 resq execve-arg2

__blue_72485894_0: resq 1
; 1 resq execve-arg3

__blue_89263513_0: resq 1
; 1 resq execve-arg4

__blue_106041132_0: resq 1
; 4 resq execve-argv

__blue_1213363986_0: resq 4
;  TODO blocked by operation size issue

section .text

; : execve-via-env ( -- noret )

__blue_2254422318_0:
	jmp __blue_1223589535_13

__blue_855163316_13:

db 101
db 110
db 118
db 0
__blue_1223589535_13:
	mov qword [__blue_188583195_0], __blue_855163316_13
	jmp __blue_1223589535_14

__blue_855163316_14:

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
__blue_1223589535_14:
	mov rdx, [__blue_2355496332_0]
	mov rsi, __blue_188583195_0
	mov rdi, __blue_855163316_14
	jmp __blue_172884385_0

;  TODO these are here to work around the operation size issue

; : set-args ( arg1:rsi arg2:rax arg3:rcx -- )

__blue_3319044491_0:
	mov qword [__blue_89263513_0], rcx
	mov qword [__blue_72485894_0], rax
	mov qword [__blue_55708275_0], rsi
	ret

; : clear-args ( -- )

__blue_480086900_0:
	xor rcx, rcx
	xor rax, rax
	xor rsi, rsi
	jmp __blue_3319044491_0

; : prep-execve ( file:rsi arg0:rax -- )

__blue_640619689_0:
	mov qword [__blue_38930656_0], rax
	mov qword [__blue_3267543346_0], rsi
	jmp __blue_480086900_0

; : generate-assembly ( -- )

__blue_2434586205_0:
	jmp __blue_1223589535_15

__blue_855163316_15:

db 98
db 108
db 117
db 101
db 0
__blue_1223589535_15:
	mov rax, [__blue_680506038_0]
	mov rsi, __blue_855163316_15
	call __blue_640619689_0
	call __blue_1046004769_0
	cmp eax, 0
	jne __blue_2157056155_4
	call __blue_2254422318_0

__blue_2157056155_4:
	mov edi, eax
	jmp __blue_3964545837_0

; : compile-assembly ( -- )

__blue_2532285537_0:
	jmp __blue_1223589535_16

__blue_855163316_16:

db 110
db 97
db 115
db 109
db 0
__blue_1223589535_16:
	mov rax, __blue_565080558_0
	mov rsi, __blue_855163316_16
	call __blue_640619689_0
	jmp __blue_1223589535_17

__blue_855163316_17:

db 45
db 102
db 0
__blue_1223589535_17:
	mov qword [__blue_55708275_0], __blue_855163316_17
	jmp __blue_1223589535_18

__blue_855163316_18:

db 101
db 108
db 102
db 54
db 52
db 0
__blue_1223589535_18:
	mov qword [__blue_72485894_0], __blue_855163316_18
	jmp __blue_1223589535_19

__blue_855163316_19:

db 45
db 111
db 0
__blue_1223589535_19:
	mov qword [__blue_89263513_0], __blue_855163316_19
	mov qword [__blue_106041132_0], __blue_496119923_0
	call __blue_1046004769_0
	cmp eax, 0
	jne __blue_2157056155_5
	call __blue_2254422318_0

__blue_2157056155_5:
	mov edi, eax
	jmp __blue_3964545837_0

; : link-binary ( -- )

__blue_838765769_0:
	jmp __blue_1223589535_20

__blue_855163316_20:

db 108
db 100
db 0
__blue_1223589535_20:
	mov rax, __blue_496119923_0
	mov rsi, __blue_855163316_20
	call __blue_640619689_0
	jmp __blue_1223589535_21

__blue_855163316_21:

db 45
db 111
db 0
__blue_1223589535_21:
	mov qword [__blue_55708275_0], __blue_855163316_21
	mov qword [__blue_72485894_0], __blue_837047421_0
	call __blue_1046004769_0
	cmp eax, 0
	jne __blue_2157056155_6
	call __blue_2254422318_0

__blue_2157056155_6:
	mov edi, eax
	jmp __blue_3964545837_0

;  TODO check wait-status after each call

; : do-build ( -- )

__blue_387804145_0:
	call __blue_2434586205_0
	call __blue_2532285537_0
	jmp __blue_838765769_0

; : build ( -- noret )

__blue_3281777315_0:
	call __blue_387804145_0
	jmp __blue_1911791459_0

;  TODO needs to forward args

; : run ( -- noret )

__blue_718098122_0:
	call __blue_387804145_0
	xor rax, rax
	mov rsi, __blue_837047421_0
	call __blue_640619689_0
	jmp __blue_2254422318_0
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
	jne __blue_2157056155_7
	call __blue_1042682684_0

__blue_2157056155_7:
	add rdi, 8
	loop __blue_612288868_0
	jmp __blue_3461590696_0

; : call-named-cmd ( name:rdx -- noret )

__blue_2780306156_0:
	call __blue_4283867725_0
	jmp __blue_2379826553_0

; : call-specified-cmd ( -- noret )

__blue_929563223_0:
	mov rdx, [__blue_1161787257_0]
	jmp __blue_2780306156_0

; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_4217555750_0
	call __blue_2670689297_0
	call __blue_747073145_0
	jmp __blue_929563223_0
