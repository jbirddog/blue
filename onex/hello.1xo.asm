include "bc.inc"

;bf 01 00 00 00          mov    edi,0x1
db	BC_EXEC_NUM
dq	0xBF
db	BC_EXEC_WORD
dq	"b,"
db	BC_EXEC_NUM
dq	0x01
db	BC_EXEC_WORD
dq	"d,"

db	BC_ED_NL

; 48 be [qword]          movabs	rsi,buf
db	BC_EXEC_NUM
dq	0xBE48
db	BC_EXEC_WORD
dq	"w,"
db	BC_DEFINE_WORD
dq	"buf"
db	BC_COMP_NUM
dq	0x00

db	BC_ED_NL

; ba [dword]              mov    edx,bufsz
db	BC_EXEC_NUM
dq	0xBA
db	BC_EXEC_WORD
dq	"b,"
db	BC_DEFINE_WORD
dq	"bufsz"
db	BC_EXEC_NUM
dq	0x00
db	BC_EXEC_WORD
dq	"d,"

db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"write"
; b8 01 00 00 00          mov    eax,0x1
db	BC_EXEC_NUM
dq	0xB8
db	BC_EXEC_WORD
dq	"b,"
db	BC_EXEC_NUM
dq	0x01
db	BC_EXEC_WORD
dq	"d,"

db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"syscall"
db	BC_EXEC_NUM
dq	0x050F
db	BC_EXEC_WORD
dq	"w,"

db	BC_ED_NL
db	BC_ED_NL

; 31 ff                   xor    edi,edi
db	BC_EXEC_NUM
dq	0xFF31
db	BC_EXEC_WORD
dq	"w,"

db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"exit"

; b0 3c			mov    al,0x3c
db	BC_EXEC_NUM
dq	0x3CB0
db	BC_EXEC_WORD
dq	"w,"

db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"syscall"

; 0f 05			syscall
db	BC_EXEC_NUM
dq	0x050F
db	BC_EXEC_WORD
dq	"w,"

db	BC_ED_NL
db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"msg"
db	BC_COMP_NUM
dq	"Hello, w"
db	BC_COMP_NUM
db	"orld!  ", 10

db	BC_ED_NL

db	BC_REF_WORD
dq	"msg"
db	BC_REF_WORD
dq	"elfhdrs"
db	BC_EXEC_WORD
dq	"-"
db	BC_EXEC_NUM
dq	0x400000
db	BC_EXEC_WORD
dq	"+"
db	BC_REF_WORD
dq	"buf"
db	BC_EXEC_WORD
dq	"!"

db	BC_ED_NL

db	BC_EXEC_WORD
dq	"$"
db	BC_REF_WORD
dq	"msg"
db	BC_EXEC_WORD
dq	"-"
db	BC_REF_WORD
dq	"bufsz"
db	BC_EXEC_WORD
dq	"d!"

db	BC_ED_NL
