include "bc.inc"

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

db	BC_NUM_PUSH
dq	0x04
db	BC_TOR
db	BC_NUM_PUSH
dq	0x50
db	BC_FROMR
db	BC_SUB
db	BC_COMMA_B

db	BC_NUM_PUSH
dq	0x50
db	BC_NUM_PUSH
dq	0x05
db	BC_OR
db	BC_COMMA_B

db	BC_NUM_PUSH
dq	0x06
db	BC_NUM_PUSH
dq	0x01
db	BC_SWAP
db	BC_SHL
db	BC_NUM_PUSH
dq	0x05
db	BC_OR
db	BC_COMMA_B

db	BC_NUM_PUSH
db	"...", 10, 0, 0, 0, 0
db	BC_COMMA_D

db	BC_FIN
