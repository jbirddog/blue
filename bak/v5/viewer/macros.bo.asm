include "bc.inc"

db	BC_WORD_DEFINE
dq	'"\n"'
db	BC_NUM_PUSH
dq	0x0A
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'" "'
db	BC_NUM_PUSH
dq	" "
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'">"'
db	BC_NUM_PUSH
dq	">"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"fin"'
db	BC_NUM_PUSH
dq	"fi"
db	BC_WORD_INTERP
dq	"w,"
db	BC_NUM_PUSH
dq	"n"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'";"'
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"swap"'
db	BC_NUM_PUSH
dq	"swap"
db	BC_WORD_INTERP
dq	"d,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"dup"'
db	BC_NUM_PUSH
dq	"du"
db	BC_WORD_INTERP
dq	"w,"
db	BC_NUM_PUSH
dq	"p"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"+"'
db	BC_NUM_PUSH
dq	"+"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"-"'
db	BC_NUM_PUSH
dq	"-"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"|"'
db	BC_NUM_PUSH
dq	"|"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"<<"'
db	BC_NUM_PUSH
dq	"<<"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'">r"'
db	BC_NUM_PUSH
dq	">r"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"r>"'
db	BC_NUM_PUSH
dq	"r>"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"$"'
db	BC_NUM_PUSH
dq	"$"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"*"'
db	BC_NUM_PUSH
dq	"*"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"b!"'
db	BC_NUM_PUSH
dq	"b!"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"!"'
db	BC_NUM_PUSH
dq	"!"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"@"'
db	BC_NUM_PUSH
dq	"@"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"$*"'
db	BC_WORD_INTERP
dq	'"$"'
db	BC_WORD_INTERP
dq	'"*"'
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"$>"'
db	BC_WORD_INTERP
dq	'"$"'
db	BC_WORD_INTERP
dq	'">"'
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"$>!"'
db	BC_WORD_INTERP
dq	'"$>"'
db	BC_WORD_INTERP
dq	'"!"'
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"b,"'
db	BC_NUM_PUSH
dq	"b,"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"w,"'
db	BC_NUM_PUSH
dq	"w,"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"d,"'
db	BC_NUM_PUSH
dq	"d,"
db	BC_WORD_INTERP
dq	"w,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'","'
db	BC_NUM_PUSH
dq	","
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"name"
db	BC_WORD_INTERP
dq	"movsq"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"num"
db	BC_WORD_INTERP
dq	"lodsq"
db	BC_WORD_END

db	BC_DSP_NL

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

db	BC_DSP_NL
db	BC_DSP_NL

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

db	BC_DSP_NL

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
db	BC_WORD_INTERP
dq	"r11"
db	BC_WORD_INTERP
dq	"rdi"
db	BC_WORD_INTERP
dq	"rex.wb"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"writedst"
db	BC_WORD_INTERP
dq	"rdx"
db	BC_WORD_INTERP
dq	"rdi"
db	BC_WORD_INTERP
dq	"rex.w"
db	BC_WORD_INTERP
dq	"mov"

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

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"save"
db	BC_WORD_INTERP
dq	"rsi"
db	BC_WORD_INTERP
dq	"push"
db	BC_WORD_INTERP
dq	"r11"
db	BC_WORD_INTERP
dq	"rex.b"
db	BC_WORD_INTERP
dq	"push"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"restore"
db	BC_WORD_INTERP
dq	"r11"
db	BC_WORD_INTERP
dq	"rex.b"
db	BC_WORD_INTERP
dq	"pop"
db	BC_WORD_INTERP
dq	"rsi"
db	BC_WORD_INTERP
dq	"pop"
db	BC_WORD_INTERP
dq	"rdi"
db	BC_WORD_INTERP
dq	"r11"
db	BC_WORD_INTERP
dq	"rex.wr"
db	BC_WORD_INTERP
dq	"mov"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
