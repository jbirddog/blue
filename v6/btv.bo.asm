include "b.inc"

db	BC_WORD_DEFINE
dq	"fin"
db	BC_WORD_INTERP
dq	"bye"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"lookup"
db	BC_WORD_RADDR
dq	"fin"
db	BC_COMMA

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"op"
db	BC_WORD_RADDR
dq	"lookup"
db	BC_WORD_INTERP
dq	"dispatch"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_DOLLAR_RADDR
db	BC_WORD_CADDR
dq	"entry"
db	BC_SET

db	BC_ED_NL

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"inbuf"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0xBA
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_COMMA_D

db	BC_WORD_INTERP
dq	"readin"

db	BC_ED_NL

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"src"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0xBF48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"dst"
db	BC_NUM_COMP
dq	0x00
db	BC_ED_NL
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_DOLLAR_RADDR
db	BC_WORD_CADDR
dq	"dst"
db	BC_SET

db	BC_ED_NL

db	BC_DOLLAR_RADDR
db	BC_WORD_INTERP
dq	"dstsz"
db	BC_ADD
db	BC_DUP
db	BC_WORD_CADDR
dq	"inbuf"
db	BC_SET
db	BC_WORD_CADDR
dq	"src"
db	BC_SET

db	BC_ED_NL
