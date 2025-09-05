include "bc.inc"

db	BC_WORD_DEFINE
dq	"fin"
db	BC_WORD_INTERP
dq	"writedst"
db	BC_WORD_INTERP
dq	"bye"

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_define"
db	BC_WORD_INTERP
dq	"lodsq"
db	BC_WORD_INTERP
dq	"denext"
db	BC_WORD_INTERP
dq	"name!"
db	BC_WORD_INTERP
dq	"codeptr!"
db	BC_WORD_INTERP
dq	"srcptr!"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_end"
db	BC_WORD_INTERP
dq	"reg.lvl"
db	BC_WORD_INTERP
dq	"if>0"
db	BC_WORD_INTERP
dq	"reg.lvl"
db	BC_WORD_INTERP
dq	"dec"
db	BC_WORD_INTERP
dq	"reg.src"
db	BC_WORD_INTERP
dq	"pop"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END
db	BC_WORD_INTERP
dq	"then"
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	".toplvl"
db	BC_WORD_INTERP
dq	"grnword?"
db	BC_WORD_INTERP
dq	"tco"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END
db	BC_WORD_INTERP
dq	"then"
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	".cret"
db	BC_NUM_PUSH
dq	0xC3
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_ccall"
db	BC_WORD_RCALL
dq	"xt"
db	BC_WORD_INTERP
dq	"call"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_rcall"
db	BC_NUM_PUSH
dq	0xE8
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_RCALL
dq	"xt"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_INTERP
dq	"reg.dst"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"sub"
db	BC_WORD_INTERP
dq	"rax"
db	BC_NUM_PUSH
dq	0x04
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"subi8"
db	BC_WORD_INTERP
dq	"stosd"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_interp"
db	BC_WORD_RCALL
dq	"find"
db	BC_WORD_INTERP
dq	"reg.src"
db	BC_WORD_INTERP
dq	"push"
db	BC_WORD_INTERP
dq	"reg.lvl"
db	BC_WORD_INTERP
dq	"inc"
; TODO: 48 8b 70 10             mov    rsi,QWORD PTR [rax+0x10]
db	BC_NUM_PUSH
dq	0x1070'8b48
db	BC_COMMA_D
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_caddr"
db	BC_WORD_RCALL
dq	"xt"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"w_raddr"
db	BC_WORD_RCALL
dq	"xt"
db	BC_WORD_DEFINE
dq	"raddr"
db	BC_WORD_INTERP
dq	"-dstbase"
db	BC_WORD_INTERP
dq	"+org"
db	BC_WORD_RCALL
dq	"dspush"
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
dq	"ds_swap"
db	BC_WORD_RCALL
dq	"dspop2"
db	BC_WORD_INTERP
dq	"xchg"
db	BC_WORD_RCALL
dq	"dspush2"
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
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"rex.w"
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
dq	"dspop2"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"sub"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_or"
db	BC_WORD_RCALL
dq	"dspop2"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"or"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds_shl"
db	BC_WORD_RCALL
dq	"dspop2"
db	BC_WORD_INTERP
dq	"shl"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"tor"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"push"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"fromr"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"pop"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_caddr"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_INTERP
dq	"reg.dst"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"$_raddr"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_INTERP
dq	"reg.dst"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_RCALL
dq	"raddr"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_INTERP
dq	"reg.dstb"
db	BC_WORD_INTERP
dq	"rex.wr"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"dstbase!"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"reg.dstb"
db	BC_WORD_INTERP
dq	"rax"
db	BC_WORD_INTERP
dq	"rex.wb"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"set_b"
db	BC_WORD_INTERP
dq	"reg.tos2"
db	BC_WORD_INTERP
dq	"reg.tos"
db	BC_WORD_INTERP
dq	"b!"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"k_set"
db	BC_WORD_RCALL
dq	"dspop2"
db	BC_WORD_INTERP
dq	"set"
db	BC_WORD_RCALL
dq	"dspush"
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"k_fetch"
db	BC_WORD_RCALL
dq	"dspop"
db	BC_WORD_INTERP
dq	"fetch"
db	BC_WORD_RCALL
dq	"dspush"
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
