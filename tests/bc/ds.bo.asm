include "b.inc"

db	BC_NUM_PUSH
db	"Blue...", 10
db	BC_DUP
db	BC_COMMA
db	BC_COMMA

db	BC_NUM_PUSH
dq	0x21
db	BC_DUP
db	BC_ADD
db	BC_COMMA_B

db	BC_FIN
