include "b.inc"

db	BC_WORD_DEFINE
dq	"msg"
db	BC_NUM_COMP
dq	"Hello, w"
db	BC_NUM_COMP
db	"orld!!!", 10

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"main"
db	BC_DOLLAR_RADDR
db	BC_WORD_CADDR
dq	"entry"
db	BC_SET

db	BC_ED_NL

db	BC_WORD_RADDR
dq	"msg"
db	BC_DOLLAR_CADDR
db	BC_WORD_CADDR
dq	"msg"
db	BC_SUB
db	BC_WORD_INTERP
dq	"print"

db	BC_ED_NL

db	BC_WORD_INTERP
dq	"bye"

db	BC_ED_NL
