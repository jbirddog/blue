include "b.inc"

db	BC_WORD_DEFINE
dq	"exit"
db	BC_NUM_PUSH
dq	0x3C
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_ED_NL
