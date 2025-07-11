include "bc.inc"

db	BC_ED_NL
db	BC_DEFINE_WORD
dq	"dil!"

; 40 b7 07		mov    dil,0x7
db	BC_COMP_BYTE, 0x40
db	BC_COMP_BYTE, 0xB7

db	BC_ED_NL
db	BC_DEFINE_WORD
dq	"status"

db	BC_COMP_BYTE, 0x07

db	BC_ED_NL
db	BC_DEFINE_WORD
dq	"exit"

; b0 3c			mov    al,0x3c
db	BC_COMP_BYTE, 0xB0
db	BC_COMP_BYTE, 0x3C

db	BC_ED_NL

db	BC_DEFINE_WORD
dq	"syscall"

; 0f 05			syscall
db	BC_COMP_BYTE, 0x0F
db	BC_COMP_BYTE, 0x05

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
