include "b.inc"

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"op"
db	BC_WORD_INTERP
dq	"eax"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"lodsb"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

