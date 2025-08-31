include "bc.inc"

db	BC_WORD_DEFINE
dq	"magic"
db	BC_NUM_COMP
dd	"BLUE", "5"

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dspush"
db	BC_WORD_INTERP
dq	"ds!"
db	BC_WORD_INTERP
dq	"ds++"
db	BC_WORD_INTERP
dq	"dsclamp"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dspush2"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dspop"
db	BC_WORD_INTERP
dq	"ds--"
db	BC_WORD_INTERP
dq	"dsclamp"
db	BC_WORD_INTERP
dq	"ds@"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dspop2"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"keep"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"find"
db	BC_WORD_INTERP
dq	"last>r"
db	BC_WORD_INTERP
dq	"lodsq"

db	BC_WORD_DEFINE
dq	"check"
db	BC_WORD_INTERP
dq	"cmpname"
db	BC_WORD_INTERP
dq	"ifeq"
db	BC_WORD_INTERP
dq	"last"
db	BC_WORD_INTERP
dq	"r>last"
db	BC_WORD_END
db	BC_WORD_INTERP
dq	"then"
db	BC_WORD_INTERP
dq	"deprev"
db	BC_WORD_RCALL
dq	"check"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"xt"
db	BC_WORD_RCALL
dq	"find"
db	BC_WORD_INTERP
dq	"codeptr"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"opcode"
db	BC_WORD_INTERP
dq	"dispatch"

db	BC_DSP_NL
db	BC_DSP_NL
