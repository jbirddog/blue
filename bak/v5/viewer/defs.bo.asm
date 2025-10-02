include "bc.inc"

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_NUM_PUSH
dq	0x2000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x500
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"resmemsz"
db	BC_WORD_INTERP
dq	"dstsz"
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_ADD
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
