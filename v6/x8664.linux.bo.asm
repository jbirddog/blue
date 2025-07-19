include "b.inc"

db	BC_ED_NL
db	BC_WORD_DEFINE
dq	"read"
db	BC_WORD_INTERP
dq	"eax"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"ok"
db	BC_WORD_INTERP
dq	"edi"
db	BC_WORD_INTERP
dq	"!0"

db	BC_WORD_DEFINE
dq	"exit"
db	BC_NUM_PUSH
dq	0x3C
db	BC_WORD_INTERP
dq	"eax!"
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL
