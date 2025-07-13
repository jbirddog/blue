include "bc.inc"

db	BC_ED_NL

db	BC_EXEC_WORD
dq	"$"
db	BC_REF_WORD
dq	"elfhdrs"
db	BC_EXEC_WORD
dq	"-"

db	BC_EXEC_WORD
dq	"dup"

db	BC_REF_WORD
dq	"elfbsz"
db	BC_EXEC_WORD
dq	"!"

db	BC_REF_WORD
dq	"elfmsz"
db	BC_EXEC_WORD
dq	"!"

db	BC_ED_NL

db	BC_REF_WORD
dq	"elfhdrs"
db	BC_REF_WORD
dq	"$$"
db	BC_EXEC_WORD
dq	"!"

db	BC_FIN
