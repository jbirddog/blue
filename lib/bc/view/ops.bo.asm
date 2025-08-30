include "bc.inc"

db	BC_WORD_DEFINE
dq	"fin"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"fin"'
db	BC_WORD_RCALL
dq	"exits"
db	BC_WORD_END
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_define"
db	BC_WORD_INTERP
dq	"red"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_end"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'";"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_ccall"
db	BC_WORD_INTERP
dq	"yellow"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_rcall"
db	BC_WORD_INTERP
dq	"green"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_interp"
db	BC_WORD_INTERP
dq	"cyan"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_caddr"
db	BC_WORD_INTERP
dq	"magenta"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_raddr"
db	BC_WORD_INTERP
dq	"white"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num_comp"
db	BC_WORD_INTERP
dq	"green"
db	BC_WORD_RCALL
dq	"hexnum"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num_push"
db	BC_WORD_INTERP
dq	"yellow"
db	BC_WORD_RCALL
dq	"hexnum"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_swap"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"swap"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_dup"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"dup"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_add"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"+"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_sub"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"-"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_or"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"|"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_shl"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"<<"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_caddr"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_raddr"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$*"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$>"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase!"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$>!"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"k_set"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"!"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"k_fetch"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"@"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_b"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"b,"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_w"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"w,"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma_d"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"d,"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"comma"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'","'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dsp_nl"
db	BC_WORD_INTERP
dq	'"\n"'
db	BC_WORD_RCALL
dq	"dstout"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
