include "bc.inc"

db	BC_WORD_DEFINE
dq	"msg"
db	BC_NUM_COMP
dq	"Hello, w"
db	BC_NUM_COMP
db	"orld!  ", 10

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"greet"
db	BC_WORD_RADDR
dq	"msg"
db	BC_WORD_EXEC
dq	"$"
db	BC_WORD_CADDR
dq	"msg"
db	BC_SUB
db	BC_WORD_INTERP
dq	"print"

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"bye"
db	BC_WORD_INTERP
dq	"ok"
db	BC_WORD_INTERP
dq	"exit"

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_RADDR
dq	"greet"
db	BC_WORD_CADDR
dq	"entry"
db	BC_WORD_EXEC
dq	"!"

db	BC_ED_NL
