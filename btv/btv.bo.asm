include "b.inc"

db	BC_WORD_DEFINE
dq	"dstout"
db	BC_WORD_INTERP
dq	"writedst"
db	BC_WORD_END
db	BC_ED_NL

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
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"vizop"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"yellow"
db	BC_WORD_INTERP
dq	"and"
db	BC_WORD_INTERP
dq	"bold"
db	BC_WORD_INTERP
dq	"and"
db	BC_WORD_INTERP
dq	"italic"
db	BC_WORD_INTERP
dq	"shows"
db	BC_WORD_END
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"word"
db	BC_WORD_INTERP
dq	"and"
db	BC_WORD_INTERP
dq	"bold"
db	BC_WORD_INTERP
dq	"shows"
db	BC_WORD_INTERP
dq	"name"
db	BC_WORD_END
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"hexnum"
db	BC_WORD_INTERP
dq	"and"
db	BC_WORD_INTERP
dq	"bold"
db	BC_WORD_INTERP
dq	"shows"
db	BC_WORD_INTERP
dq	"num"
db	BC_WORD_INTERP
dq	"ashex"
db	BC_WORD_END
db	BC_ED_NL

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"fin"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"fin"'
db	BC_WORD_RCALL
dq	"exits"
db	BC_WORD_END
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_define"
db	BC_WORD_INTERP
dq	"red"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_end"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'";"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_ccall"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"yellow"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_rcall"
db	BC_WORD_INTERP
dq	"green"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_interp"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"cyan"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_caddr"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"magenta"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_raddr"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"white"
db	BC_WORD_RCALL
dq	"word"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"num_comp"
db	BC_WORD_INTERP
dq	"green"
db	BC_WORD_RCALL
dq	"hexnum"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"num_push"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"yellow"
db	BC_WORD_RCALL
dq	"hexnum"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"dup"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"dup"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"add"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"+"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"sub"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"-"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"or"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"or"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"shl"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"shl"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"$_caddr"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"$_raddr"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$*"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"dstbase"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$>"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"dstbase!"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"$>!"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"set"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"!"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"fetch"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"@"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"comma_b"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"b,"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"comma_w"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"w,"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"comma_d"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'"d,"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"comma"
db	BC_WORD_RCALL
dq	"vizop"
db	BC_WORD_INTERP
dq	'","'
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"ed_nl"
db	BC_WORD_INTERP
dq	'"\n"'
db	BC_WORD_END

db	BC_ED_NL

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"lookup"
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"fin"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"w_define"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_end"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_ccall"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_rcall"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_interp"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_caddr"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_raddr"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"num_comp"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"num_push"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"dup"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"add"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"sub"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"or"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"shl"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"$_caddr"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"$_raddr"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"dstbase"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"dstbase!"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"set"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"fetch"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"comma_b"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"comma_w"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"comma_d"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"comma"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"ed_nl"
db	BC_COMMA

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"main"
db	BC_DOLLAR_RADDR
db	BC_WORD_CADDR
dq	"entry"
db	BC_SET
db	BC_WORD_INTERP
dq	"readsrc"
db	BC_WORD_INTERP
dq	"init"

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"opcode"
db	BC_WORD_RADDR
dq	"lookup"
db	BC_WORD_INTERP
dq	"dispatch"
db	BC_WORD_INTERP
dq	"reset"
db	BC_WORD_INTERP
dq	'" "'
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_DOLLAR_RADDR
db	BC_DUP
db	BC_WORD_CADDR
dq	"outbuf"
db	BC_SET
db	BC_WORD_CADDR
dq	"dst"
db	BC_SET

db	BC_ED_NL

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

db	BC_ED_NL
