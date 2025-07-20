include "b.inc"

db	BC_WORD_DEFINE
dq	"fin"
db	BC_ED_NL

db	BC_WORD_INTERP
dq	"\n"
db	BC_ED_NL

; mov rdx, rdi
db	BC_NUM_PUSH
dq	0x8948
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xFA
db	BC_COMMA_B
db	BC_ED_NL

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"outbuf"
db	BC_NUM_COMP
dq	0x00
db	BC_ED_NL

; sub rdx, rsi
db	BC_NUM_PUSH
dq	0x2948
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xF2
db	BC_COMMA_B
db	BC_ED_NL

db	BC_WORD_INTERP
dq	"writeout"
db	BC_WORD_INTERP
dq	"bye"

db	BC_ED_NL
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
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"al!"
db	BC_WORD_INTERP
dq	"stosb"
db	BC_WORD_END

db	BC_ED_NL

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"handler"
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

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"next"
db	BC_WORD_INTERP
dq	"opcode"
db	BC_WORD_RADDR
dq	"handler"
db	BC_WORD_INTERP
dq	"dispatch"
db	BC_WORD_INTERP
dq	"reset"
db	BC_WORD_INTERP
;dq	"sp"
dq	'" "'
db	BC_WORD_RCALL
dq	"next"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_DOLLAR_RADDR
db	BC_WORD_CADDR
dq	"entry"
db	BC_SET

db	BC_ED_NL

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"inbuf"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0xBA
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_COMMA_D

db	BC_WORD_INTERP
dq	"readin"

db	BC_ED_NL

db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"src"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0xBF48
db	BC_COMMA_W
db	BC_WORD_DEFINE
dq	"dst"
db	BC_NUM_COMP
dq	0x00
db	BC_ED_NL
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
