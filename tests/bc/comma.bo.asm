include "bc.inc"

db	BC_NUM_PUSH
dq	"AAAAAAAA"
db	BC_COMMA

db	BC_NUM_PUSH
dq	"BBBB"
db	BC_COMMA_D

db	BC_NUM_PUSH
dq	"CC"
db	BC_COMMA_W

db	BC_NUM_PUSH
dq	0x0A
db	BC_COMMA_B

db	BC_FIN
