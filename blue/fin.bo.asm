include "b.inc"

db	BC_DOLLAR_RADDR
db	BC_DUP
db	BC_WORD_CADDR
dq	"outbuf"
db	BC_SET
db	BC_WORD_CADDR
dq	"dst"
db	BC_SET

db	BC_DSP_NL

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

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_RADDR
dq	"main"
db	BC_WORD_CADDR
dq	"entry"
db	BC_SET


db	BC_DOLLAR_CADDR
db	BC_DST_BASE
db	BC_SUB

db	BC_DUP

db	BC_WORD_CADDR
dq	"elfbsz"
db	BC_SET

db	BC_WORD_INTERP
dq	"dstsz"
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_ADD

db	BC_ADD

db	BC_WORD_CADDR
dq	"elfmsz"
db	BC_SET

db	BC_DSP_NL
db	BC_DSP_NL
