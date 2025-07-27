include "b.inc"

db	BC_ED_NL

db	BC_DOLLAR_CADDR
db	BC_WORD_CADDR
dq	"elfhdrs"
db	BC_SUB

db	BC_DUP

db	BC_WORD_CADDR
dq	"elfbsz"
db	BC_SET

db	BC_WORD_CADDR
dq	"elfmsz"
db	BC_SET

db	BC_FIN
