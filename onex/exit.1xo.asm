include "bc.inc"

db	BC_WORD_DEFINE
dq	"exit"

; b0 3c			mov    al,0x3c
db	BC_NUM_EXEC
dq	0x3CB0
db	BC_COMMA_W

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"syscall"

; 0f 05			syscall
db	BC_NUM_EXEC
dq	0x050F
db	BC_COMMA_W

db	BC_ED_NL
