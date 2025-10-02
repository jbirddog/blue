include "bc.inc"

db	BC_WORD_DEFINE
dq	"w"
db	BC_NUM_PUSH
dq	0x00
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"movz"
db	BC_NUM_PUSH
dq	0x05
db	BC_SHL
db	BC_OR
db	BC_NUM_PUSH
dq	0x5280'0000
db	BC_OR
db	BC_OR
db	BC_COMMA_D
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"svc"
db	BC_NUM_PUSH
dq	0x05
db	BC_SHL
db	BC_NUM_PUSH
dq	0xD400'0001
db	BC_OR
db	BC_COMMA_D
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
