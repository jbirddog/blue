include "bc.inc"

db	BC_WORD_DEFINE
dq	"main"
db	BC_WORD_INTERP
dq	"readsrc"
db	BC_WORD_INTERP
dq	"initsd"
db	BC_WORD_INTERP
dq	"dsinit"
db	BC_WORD_INTERP
dq	"dictinit"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
