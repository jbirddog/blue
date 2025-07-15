include "bc.inc"

db	BC_WORD_DEFINE
dq	"syscall"
db	BC_NUM_EXEC
dq	0x050F
db	BC_WORD_EXEC
dq	"w,"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL
