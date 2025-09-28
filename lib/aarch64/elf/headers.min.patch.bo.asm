include "bc.inc"

db	BC_DSP_NL

db	BC_NUM_PUSH
dq	0xB7

db	BC_WORD_CADDR
dq	"elfhdrs"
db	BC_NUM_PUSH
dq	0x12
db	BC_ADD

db	BC_SET_B

db	BC_NUM_PUSH
dq	0x05

db	BC_WORD_CADDR
dq	"elfhdrs"
db	BC_NUM_PUSH
dq	0x33
db	BC_ADD

db	BC_SET_B
