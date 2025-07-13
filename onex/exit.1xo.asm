include "bc.inc"

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
