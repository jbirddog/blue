include "b.inc"

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x1000
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"opcode"
db	BC_WORD_INTERP
dq	"eax"
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"lodsb"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dispatch"
db	BC_NUM_PUSH
dq	0x14FF
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xC5
db	BC_COMMA_B
db	BC_COMMA_D
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"bout"
db	BC_WORD_INTERP
dq	"al!"
db	BC_WORD_INTERP
dq	"stosb"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"wout"
db	BC_WORD_INTERP
dq	"ax!"
db	BC_WORD_INTERP
dq	"stosw"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dout"
db	BC_WORD_INTERP
dq	"eax!"
db	BC_WORD_INTERP
dq	"stosd"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	'"\n"'
db	BC_NUM_PUSH
dq	0x0A
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'" "'
db	BC_NUM_PUSH
dq	" "
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'";"'
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	'"fin"'
db	BC_NUM_PUSH
dq	"fi"
db	BC_WORD_INTERP
dq	"wout"
db	BC_NUM_PUSH
dq	"n"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"reset"
db	BC_NUM_PUSH
db	0x1B, "[0m", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"is"
db	BC_NUM_PUSH
db	0x1B, "[", 0, 0, 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"and"
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"shows"
db	BC_NUM_PUSH
dq	"m"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"red"
db	BC_NUM_PUSH
dq	"31"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"green"
db	BC_NUM_PUSH
dq	"32"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"yellow"
db	BC_NUM_PUSH
dq	"33"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"cyan"
db	BC_NUM_PUSH
dq	"36"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"bold"
db	BC_NUM_PUSH
dq	"1"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"italic"
db	BC_NUM_PUSH
dq	"3"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"name"
db	BC_WORD_INTERP
dq	"movsq"
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"num"
db	BC_NUM_PUSH
dq	"FF"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"readsrc"
db	BC_WORD_INTERP
dq	"rsi="
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
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"init"
db	BC_WORD_INTERP
dq	"rsi="
db	BC_WORD_DEFINE
dq	"src"
db	BC_NUM_COMP
dq	0x00
db	BC_WORD_INTERP
dq	"rdi="
db	BC_WORD_DEFINE
dq	"dst"
db	BC_NUM_COMP
dq	0x00
db	BC_WORD_END

db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"writedst"
; mov rdx, rdi
db	BC_NUM_PUSH
dq	0x8948
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xFA
db	BC_COMMA_B

db	BC_WORD_INTERP
dq	"rsi="
db	BC_WORD_DEFINE
dq	"outbuf"
db	BC_NUM_COMP
dq	0x00

; sub rdx, rsi
db	BC_NUM_PUSH
dq	0x2948
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xF2
db	BC_COMMA_B

db	BC_WORD_INTERP
dq	"writeout"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL
