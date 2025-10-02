include "bc.inc"

db	BC_WORD_DEFINE
dq	"dstout"
db	BC_WORD_INTERP
dq	"save"
db	BC_WORD_INTERP
dq	"writedst"
db	BC_WORD_INTERP
dq	"restore"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"exits"
db	BC_WORD_INTERP
dq	"reset"
db	BC_WORD_INTERP
dq	'"\n"'
db	BC_WORD_RCALL
dq	"dstout"
db	BC_WORD_INTERP
dq	"bye"
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"word"
db	BC_WORD_INTERP
dq	"shows"
db	BC_WORD_INTERP
dq	"name"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"hexnum"
db	BC_WORD_INTERP
dq	"shows"
db	BC_WORD_INTERP
dq	"num"
db	BC_WORD_INTERP
dq	"ashex"
db	BC_WORD_END

db	BC_DSP_NL
