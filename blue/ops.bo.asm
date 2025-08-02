include "b.inc"

db	BC_WORD_DEFINE
dq	"fin"
db	BC_WORD_INTERP
dq	"writedst"
db	BC_WORD_INTERP
dq	"bye"

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_define"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_end"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_ccall"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_rcall"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_interp"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_caddr"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_raddr"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num_comp"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num_push"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dup"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"add"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"sub"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"or"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"shl"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_caddr"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_raddr"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase!"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"set"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"fetch"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_b"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_w"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_d"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dsp_nl"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
