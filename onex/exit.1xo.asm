include "bc.inc"

db	BC_ED_NL
db	BC_DEFINE_WORD
dq	"dil!"

; 40 b7 07		mov    dil,0x7
db	BC_EXEC_NUM
dq	0xB740
db	BC_EXEC_WORD
dq	"w,"

db	BC_ED_NL
db	BC_DEFINE_WORD
dq	"status"

db	BC_EXEC_NUM
dq	0x07
db	BC_EXEC_WORD
dq	"b,"

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

db	BC_EXEC_WORD
dq	"dstsz"

db	BC_REF_WORD
dq	"elfbsz"

db	BC_EXEC_WORD
dq	"!"
db	BC_ED_NL

db	BC_EXEC_WORD
dq	"dstsz"

db	BC_REF_WORD
dq	"elfmsz"

db	BC_EXEC_WORD
dq	"!"

db	BC_FIN
