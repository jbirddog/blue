include "bc.inc"

db	BC_ED_NL

db	BC_WORD_EXEC
dq	"$"
db	BC_WORD_CADDR
dq	"elfhdrs"
db	BC_WORD_EXEC
dq	"-"

db	BC_WORD_EXEC
dq	"dup"

db	BC_WORD_CADDR
dq	"elfbsz"
db	BC_WORD_EXEC
dq	"!"

db	BC_WORD_CADDR
dq	"elfmsz"
db	BC_WORD_EXEC
dq	"!"


db	BC_ED_NL
db	BC_ED_NL

db	BC_FIN
