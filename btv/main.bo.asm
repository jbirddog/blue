include "bc.inc"

db	BC_WORD_DEFINE
dq	"main"
db	BC_WORD_INTERP
dq	"readsrc"
db	BC_WORD_INTERP
dq	"init"

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"opcode"
db	BC_WORD_RADDR
dq	"lookup"
db	BC_WORD_INTERP
dq	"dispatch"
db	BC_WORD_INTERP
dq	"reset"
db	BC_WORD_INTERP
dq	'" "'
db	BC_WORD_RCALL
dq	"dstout?"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
