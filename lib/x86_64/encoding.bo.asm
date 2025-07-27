include "b.inc"

db	BC_WORD_DEFINE
dq	"eax"
db	BC_NUM_PUSH
dq	0x00
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edx"
db	BC_NUM_PUSH
dq	0x02
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"esi"
db	BC_NUM_PUSH
dq	0x06
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edi"
db	BC_NUM_PUSH
dq	0x07
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"/0"
db	BC_NUM_PUSH
dq	0xC0
db	BC_OR
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"/r"
db	BC_NUM_PUSH
dq	0x03
db	BC_SHL
db	BC_OR
db	BC_WORD_INTERP
dq	"/0"
db	BC_WORD_END

db	BC_ED_NL
