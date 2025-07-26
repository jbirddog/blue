include "b.inc"

db	BC_WORD_DEFINE
dq	"w_define"

db	BC_WORD_END

db	BC_WORD_CCALL
dq	"w_ccall"

db	BC_WORD_RCALL
dq	"w_rcall"

db	BC_WORD_INTERP
dq	"w_interp"

db	BC_WORD_CADDR
dq	"w_caddr"

db	BC_WORD_RADDR
dq	"w_raddr"

db	BC_NUM_COMP
dq	"TODO: AA"

db	BC_NUM_PUSH
dq	"TODO: BB"

db	BC_DUP
db	BC_ADD
db	BC_SUB
db	BC_OR
db	BC_SHL

db	BC_DOLLAR_CADDR
db	BC_DOLLAR_RADDR
db	BC_SET
db	BC_FETCH
db	BC_COMMA_B
db	BC_COMMA_W
db	BC_COMMA_D
db	BC_COMMA

db	BC_ED_NL

db	BC_FIN
