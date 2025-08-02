include "b.inc"

db	BC_WORD_DEFINE
dq	"magic"
db	BC_NUM_COMP
dd	"BLUE", "5"

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"opcode"
db	BC_WORD_INTERP
dq	"dispatch"

db	BC_DSP_NL
db	BC_DSP_NL
