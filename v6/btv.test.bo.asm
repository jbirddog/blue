include "b.inc"

db	BC_WORD_DEFINE
dq	"someword"

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

db	BC_FIN
