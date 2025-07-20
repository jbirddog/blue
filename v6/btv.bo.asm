include "b.inc"

db	BC_WORD_DEFINE
dq	"exists"
db	BC_WORD_INTERP
dq	"reset"
db	BC_WORD_INTERP
dq	'"\n"'
db	BC_WORD_INTERP
dq	"writedst"
db	BC_WORD_INTERP
dq	"bye"
db	BC_WORD_END
db	BC_ED_NL

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"fin"
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
db	BC_WORD_INTERP
dq	'"fin"'
db	BC_WORD_RCALL
dq	"exists"
db	BC_WORD_END
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"w_def"
db	BC_WORD_INTERP
dq	"is"
db	BC_WORD_INTERP
dq	"red"
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
dq	"w_end"
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

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"lookup"
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"fin"
db	BC_COMMA
db	BC_ED_NL
db	BC_WORD_RADDR
dq	"w_def"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_end"
db	BC_COMMA
db	BC_WORD_RADDR
dq	"w_ccall"
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
