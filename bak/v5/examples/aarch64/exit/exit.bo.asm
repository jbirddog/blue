include "bc.inc"

db	BC_WORD_INTERP
dq	"w"
db	BC_NUM_PUSH
dq	0x00
db	BC_NUM_PUSH
dq	0x00
db	BC_WORD_INTERP
dq	"movz"

db	BC_DSP_NL

db	BC_WORD_INTERP
dq	"w"
db	BC_NUM_PUSH
dq	0x08
db	BC_NUM_PUSH
dq	0x5D
db	BC_WORD_INTERP
dq	"movz"

db	BC_DSP_NL

db	BC_NUM_PUSH
dq	0x00
db	BC_WORD_INTERP
dq	"svc"

db	BC_DSP_NL
