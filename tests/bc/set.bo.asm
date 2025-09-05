include "bc.inc"

db	BC_NUM_COMP
dq	0x0

db	BC_NUM_PUSH
dq	"XlueBLUE"
db	BC_DST_BASE
db	BC_SET

db	BC_NUM_PUSH
dq	"b"
db	BC_DST_BASE
db	BC_SET_B

db	BC_NUM_PUSH
dq	0x0A
db	BC_COMMA_B

db	BC_FIN
