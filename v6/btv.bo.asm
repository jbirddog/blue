include "b.inc"

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"srcptr"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0xBA
db	BC_COMMA_B
db	BC_WORD_DEFINE
dq	"srclen"
db	BC_NUM_PUSH
dq	0x1000
db	BC_COMMA_D

db	BC_WORD_INTERP
dq	"edi"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"read"

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_INTERP
dq	"bye"

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"dstbuf"

db	BC_WORD_DEFINE
dq	"srcbuf"

db	BC_WORD_CADDR
dq	"srcbuf"
db	BC_WORD_CADDR
dq	"srcptr"
db	BC_SET

db	BC_ED_NL
