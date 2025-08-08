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
db	BC_WORD_INTERP
dq	"movsq"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num_push"
db	BC_WORD_INTERP
dq	"lodsq"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_dup"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_add"
db	BC_WORD_RCALL
dq	"dspop2"
db	BC_WORD_INTERP
dq	"add"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_sub"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_or"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_shl"
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
dq	"dspop"
db	BC_WORD_INTERP
dq	"stosb"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_w"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"stosw"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_d"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"stosd"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"stosq"
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
