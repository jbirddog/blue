
; : @! ( src:rsi dest:rdi -- )

__blue_2950180442_0:
	movsq
	ret

;  global file descriptors

;  kernel error codes

; : syscall ( num:eax -- result:eax | rcx )

__blue_4057121178_0:
	syscall
	ret

; : exit ( status:edi -- noret )

__blue_3454868101_0:
	mov eax, 60
	call __blue_4057121178_0

; : fork ( -- result:eax )

__blue_1046004769_0:
	mov eax, 57
	call __blue_4057121178_0
	ret

; : execve ( filename:rdi argv:rsi env:rdx -- result:eax )

__blue_172884385_0:
	mov eax, 59
	call __blue_4057121178_0
	ret

; : wait4 ( pid:edi status:rsi options:rdx usage:r10 -- result:eax )

__blue_2279771388_0:
	mov eax, 61
	call __blue_4057121178_0
	ret

; : write ( buf:esi len:edx fd:edi -- result:eax )

__blue_3190202204_0:
	xor eax, eax
	inc eax
	call __blue_4057121178_0
	ret

; : mkdir ( path:edi mode:esi -- result:eax )

__blue_2883839448_0:
	mov eax, 83
	call __blue_4057121178_0
	ret

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

; : fork ( -- result )

__blue_1046004769_1:
	call __blue_1046004769_0
	call __blue_4055961022_0
	ret

; : execve ( filename argv env -- noret )

__blue_172884385_1:
	call __blue_172884385_0
	call __blue_1614081290_0

section .bss

; 1 resd wait-status

__blue_285992641_0: resd 1
;  TODO want to return wait-status @ 

;  TODO actually need ports of WIFEXITED and WEXITSTATUS

section .text

; : waitpid ( pid -- )

__blue_3964545837_0:
	xor r10, r10
	xor rdx, rdx
	mov rsi, __blue_285992641_0
	call __blue_2279771388_0
	call __blue_1614081290_0
	ret

; : mkdir ( path -- )

__blue_2883839448_1:
	mov esi, 488
	call __blue_2883839448_0
	mov edi, -17
	call __blue_2118064195_0
	ret

; : type ( buf len -- )

__blue_1361572173_0:
	xor edi, edi
	inc edi
	call __blue_3190202204_0
	call __blue_1614081290_0
	ret

section .bss

; 1 resq argc

__blue_2366279180_0: resq 1
; 1 resq argv

__blue_2584388227_0: resq 1
; 1 resq envp

__blue_2355496332_0: resq 1
section .text

; : envp-start ( base:rax argc:rcx -- start:rax )

__blue_3309500289_0:
	shl rcx, 3
	add rcx, 8
	add rax, rcx
	ret

; : nth-arg ( argv:rax nth:rcx -- arg:rax )

__blue_3382297396_0:
	shl rcx, 3
	add rax, rcx
	mov rax, qword [rax]
	ret

; : brt0 ( rax -- )

__blue_2486814297_0:
	mov rdi, __blue_2366279180_0
	mov rsi, rax
	call __blue_2950180442_0
	add rax, 8
	mov qword [__blue_2584388227_0], rax
	mov rcx, [__blue_2366279180_0]
	call __blue_3309500289_0
	mov qword [__blue_2355496332_0], rax
	ret

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

;  TODO swap drop -> nip

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
	call __blue_2360258130_0
	ret

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
	call __blue_256417459_0
	ret

; : bye ( -- noret )

__blue_1911791459_0:
	xor edi, edi
	jmp __blue_3454868101_0

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

; : usage ( -- noret )

__blue_3461590696_0:
	jmp __blue_1223589535_1

__blue_855163316_1:

db 10,117,115,97,103,101,58,32,98,97,107,101,32,99,109,100,32,115,111,109,101,102,105,108,101,46,98,108,117,101,32,91,97,114,103,115,93,10,10,99,109,100,58,10,9,98,117,105,108,100,32,9,45,32,99,111,109,112,105,108,101,32,116,104,101,32,115,112,101,99,105,102,105,101,100,32,98,108,117,101,32,102,105,108,101,10,9,114,117,110,32,9,45,32,99,111,109,112,105,108,101,32,97,110,100,32,114,117,110,32,116,104,101,32,115,112,101,99,105,102,105,101,100,32,98,108,117,101,32,102,105,108,101,10,10,91,97,114,103,115,93,58,10,9,111,112,116,105,111,110,97,108,32,97,114,103,115,32,99,97,110,32,98,101,32,112,97,115,115,101,100,32,116,111,32,99,111,109,109,97,110,100,115,58,10,10,9,98,117,105,108,100,9,45,32,110,47,97,10,9,114,117,110,9,45,32,97,114,103,115,32,116,111,32,102,111,114,119,97,114,100,32,116,111,32,116,104,101,32,98,108,117,101,32,112,114,111,103,114,97,109,32,116,111,32,114,117,110,10,0
__blue_1223589535_1:
	mov edx, 249
	mov esi, __blue_855163316_1
	call __blue_1361572173_0
	jmp __blue_1911791459_0

section .bss

; 1 resq blue-file

__blue_680506038_0: resq 1
; 1 resq cmd-name

__blue_1161787257_0: resq 1
; 1 resq cmd-args

__blue_964343155_0: resq 1
section .text

; : set-cmd-args ( -- )

__blue_4050364212_0:
	mov rcx, 3
	mov rax, [__blue_2584388227_0]
	call __blue_3382297396_0
	mov qword [__blue_964343155_0], rax
	ret

;  TODO support operation size for cmp so caller doesn't have to pass in argc

; : set-cmd-args ( argc:rax -- )

__blue_4050364212_1:
	cmp rax, 3
	jle __blue_2157056155_3
	call __blue_4050364212_0

__blue_2157056155_3:
	ret

; : check-argc ( argc:rax -- )

__blue_3569987719_0:
	cmp rax, 3
	jge __blue_2157056155_4
	call __blue_3461590696_0

__blue_2157056155_4:
	ret

; : parse-args ( -- )

__blue_4217555750_0:
	mov rax, [__blue_2366279180_0]
	call __blue_3569987719_0
	xor rcx, rcx
	inc rcx
	mov rax, [__blue_2584388227_0]
	call __blue_3382297396_0
	mov qword [__blue_1161787257_0], rax
	mov rcx, 2
	mov rax, [__blue_2584388227_0]
	call __blue_3382297396_0
	mov qword [__blue_680506038_0], rax
	mov rax, [__blue_2366279180_0]
	call __blue_4050364212_1
	ret

;  TODO compile time concat

; : build-dir ( -- )

__blue_1221549521_0:
	jmp __blue_1223589535_2

__blue_855163316_2:

db 46,98,117,105,108,100,47,0
__blue_1223589535_2:
	ret

; : bin-dir ( -- )

__blue_1480828760_0:
	jmp __blue_1223589535_3

__blue_855163316_3:

db 46,98,117,105,108,100,47,98,105,110,47,0
__blue_1223589535_3:
	ret

; : obj-dir ( -- )

__blue_264527620_0:
	jmp __blue_1223589535_4

__blue_855163316_4:

db 46,98,117,105,108,100,47,111,98,106,47,0
__blue_1223589535_4:
	ret

; : make-build-dirs ( -- )

__blue_2670689297_0:
	jmp __blue_1223589535_5

__blue_855163316_5:

db 46,98,117,105,108,100,47,0
__blue_1223589535_5:
	mov edi, __blue_855163316_5
	call __blue_2883839448_1
	jmp __blue_1223589535_6

__blue_855163316_6:

db 46,98,117,105,108,100,47,98,105,110,47,0
__blue_1223589535_6:
	mov edi, __blue_855163316_6
	call __blue_2883839448_1
	jmp __blue_1223589535_7

__blue_855163316_7:

db 46,98,117,105,108,100,47,111,98,106,47,0
__blue_1223589535_7:
	mov edi, __blue_855163316_7
	call __blue_2883839448_1
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
;  TODO should drop .blue explicitly vs taking 5 off the length...

section .text

; : build-base-file-name ( -- )

__blue_914170956_0:
	mov rdx, [__blue_680506038_0]
	call __blue_3207375596_0
	sub rdx, 5
	mov rdi, __blue_3277841025_0
	mov rcx, rdx
	call __blue_2360258130_0
	ret

; : build-assembly-file-name ( -- )

__blue_976802625_0:
	mov rdi, __blue_565080558_0
	mov rsi, __blue_3277841025_0
	call __blue_2435236535_0
	jmp __blue_1223589535_8

__blue_855163316_8:

db 46,97,115,109,0
__blue_1223589535_8:
	mov rcx, 4
	mov rsi, __blue_855163316_8
	call __blue_256417459_0
	ret

; : build-object-file-name ( -- )

__blue_3419772654_0:
	jmp __blue_1223589535_9

__blue_855163316_9:

db 46,98,117,105,108,100,47,111,98,106,47,0
__blue_1223589535_9:
	mov rdi, __blue_496119923_0
	mov rsi, __blue_855163316_9
	call __blue_2435236535_0
	mov rsi, __blue_3277841025_0
	call __blue_586198672_0
	jmp __blue_1223589535_10

__blue_855163316_10:

db 46,111,0
__blue_1223589535_10:
	mov rcx, 2
	mov rsi, __blue_855163316_10
	call __blue_256417459_0
	ret

; : build-binary-file-name ( -- )

__blue_1696784928_0:
	jmp __blue_1223589535_11

__blue_855163316_11:

db 46,98,117,105,108,100,47,98,105,110,47,0
__blue_1223589535_11:
	mov rdi, __blue_837047421_0
	mov rsi, __blue_855163316_11
	call __blue_2435236535_0
	mov rsi, __blue_3277841025_0
	call __blue_586198672_0
	ret

; : build-output-file-names ( -- )

__blue_747073145_0:
	call __blue_914170956_0
	call __blue_976802625_0
	call __blue_3419772654_0
	call __blue_1696784928_0
	ret

section .bss

; 1 resq env-file

__blue_2063802741_0: resq 1
; 1 resq env-arg0

__blue_188583195_0: resq 1
; 1 resq exec-file

__blue_667945565_0: resq 1
;  TODO blocked by operation size issue

;  4 resq exec-argv 

; 1 resq exec-arg0

__blue_871594851_0: resq 1
; 1 resq exec-arg1

__blue_854817232_0: resq 1
; 1 resq exec-arg2

__blue_905150089_0: resq 1
; 1 resq exec-arg3

__blue_888372470_0: resq 1
; 1 resq exec-arg4

__blue_938705327_0: resq 1
;  TODO uses /usr/bin/env as a crutch right now

section .text

; : execvpe ( -- noret )

__blue_279745373_0:
	jmp __blue_1223589535_12

__blue_855163316_12:

db 101,110,118,0
__blue_1223589535_12:
	mov qword [__blue_188583195_0], __blue_855163316_12
	jmp __blue_1223589535_13

__blue_855163316_13:

db 47,117,115,114,47,98,105,110,47,101,110,118,0
__blue_1223589535_13:
	mov rdx, [__blue_2355496332_0]
	mov rsi, __blue_188583195_0
	mov rdi, __blue_855163316_13
	jmp __blue_172884385_1

;  TODO these are here to work around the operation size issue

; : set-args ( arg1:rsi arg2:rax arg3:rcx -- )

__blue_3319044491_0:
	mov qword [__blue_888372470_0], rcx
	mov qword [__blue_905150089_0], rax
	mov qword [__blue_854817232_0], rsi
	ret

; : clear-args ( -- )

__blue_480086900_0:
	xor rcx, rcx
	xor rax, rax
	xor rsi, rsi
	call __blue_3319044491_0
	ret

; : prep-execve ( file:rsi arg0:rax -- )

__blue_640619689_0:
	mov qword [__blue_871594851_0], rax
	mov qword [__blue_667945565_0], rsi
	call __blue_480086900_0
	ret

; : spawn ( -- )

__blue_975326616_0:
	call __blue_1046004769_1
	cmp eax, 0
	jne __blue_2157056155_5
	call __blue_279745373_0

__blue_2157056155_5:
	mov edi, eax
	call __blue_3964545837_0
	ret

; : generate-assembly ( -- )

__blue_2434586205_0:
	jmp __blue_1223589535_14

__blue_855163316_14:

db 98,108,117,101,0
__blue_1223589535_14:
	mov rax, [__blue_680506038_0]
	mov rsi, __blue_855163316_14
	call __blue_640619689_0
	call __blue_975326616_0
	ret

; : compile-assembly ( -- )

__blue_2532285537_0:
	jmp __blue_1223589535_15

__blue_855163316_15:

db 110,97,115,109,0
__blue_1223589535_15:
	mov rax, __blue_565080558_0
	mov rsi, __blue_855163316_15
	call __blue_640619689_0
	jmp __blue_1223589535_16

__blue_855163316_16:

db 45,102,0
__blue_1223589535_16:
	mov qword [__blue_854817232_0], __blue_855163316_16
	jmp __blue_1223589535_17

__blue_855163316_17:

db 101,108,102,54,52,0
__blue_1223589535_17:
	mov qword [__blue_905150089_0], __blue_855163316_17
	jmp __blue_1223589535_18

__blue_855163316_18:

db 45,111,0
__blue_1223589535_18:
	mov qword [__blue_888372470_0], __blue_855163316_18
	mov qword [__blue_938705327_0], __blue_496119923_0
	call __blue_975326616_0
	ret

; : link-binary ( -- )

__blue_838765769_0:
	jmp __blue_1223589535_19

__blue_855163316_19:

db 108,100,0
__blue_1223589535_19:
	mov rax, __blue_496119923_0
	mov rsi, __blue_855163316_19
	call __blue_640619689_0
	jmp __blue_1223589535_20

__blue_855163316_20:

db 45,111,0
__blue_1223589535_20:
	mov qword [__blue_854817232_0], __blue_855163316_20
	mov qword [__blue_905150089_0], __blue_837047421_0
	call __blue_975326616_0
	ret

;  TODO check wait-status after each call

; : build ( -- )

__blue_3281777315_0:
	call __blue_2434586205_0
	call __blue_2532285537_0
	call __blue_838765769_0
	ret

; : exec-arg0! ( rax -- )

__blue_172689638_0:
	mov qword [__blue_871594851_0], rax
	ret

;  TODO needs to forward args

; : run ( -- noret )

__blue_718098122_0:
	call __blue_3281777315_0

;  binary-file exec-file !

;  cmd-args exec-arg0 ! 
	mov rax, [__blue_964343155_0]
	mov rsi, __blue_837047421_0
	call __blue_640619689_0
	jmp __blue_279745373_0

; :: cmd-table

__blue_758800390_0:

db 0,0,0,98,117,105,108,100
dq __blue_3281777315_0
db 0,0,0,0,0,114,117,110
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
	call __blue_1785978521_0
	ret

; : call-cmd ( cmd:rdi -- noret )

__blue_1042682684_0:
	call qword [rdi]
	jmp __blue_1911791459_0

; : call-cmd-with-key ( key:rax -- noret )

__blue_2379826553_0:
	mov rdi, __blue_758800390_0
	mov ecx, 2

; : scan-cmd-table ( tries:ecx tbl:rdi key:rax -- noret )

__blue_612288868_0:
	scasq
	jne __blue_2157056155_6
	call __blue_1042682684_0

__blue_2157056155_6:
	add rdi, 8
	loop __blue_612288868_0
	jmp __blue_3461590696_0

; : call-named-cmd ( name -- noret )

__blue_2780306156_0:
	call __blue_4283867725_0
	jmp __blue_2379826553_0

; : call-specified-cmd ( -- noret )

__blue_929563223_0:
	mov rdx, [__blue_1161787257_0]
	jmp __blue_2780306156_0

global _start

; : _start ( rsp -- noret )

_start:
	mov rax, rsp
	call __blue_2486814297_0
	call __blue_4217555750_0
	call __blue_2670689297_0
	call __blue_747073145_0
	jmp __blue_929563223_0
