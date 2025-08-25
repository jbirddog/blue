include "bc.inc"

db	BC_WORD_DEFINE
dq	"srcsz"
db	BC_NUM_PUSH
dq	0x2000
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"dstsz"
db	BC_NUM_PUSH
dq	0x500
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"resmemsz"
db	BC_WORD_INTERP
dq	"dstsz"
db	BC_WORD_INTERP
dq	"srcsz"
db	BC_ADD
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

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

db	BC_DSP_NL

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

db	BC_DSP_NL

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

db	BC_WORD_DEFINE
dq	'";"'
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"dup"'
db	BC_NUM_PUSH
dq	"du"
db	BC_WORD_INTERP
dq	"wout"
db	BC_NUM_PUSH
dq	"p"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"+"'
db	BC_NUM_PUSH
dq	"+"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"-"'
db	BC_NUM_PUSH
dq	"-"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"|"'
db	BC_NUM_PUSH
dq	"|"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"<<"'
db	BC_NUM_PUSH
dq	"<<"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	'"$"'
db	BC_NUM_PUSH
dq	"$"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"*"'
db	BC_NUM_PUSH
dq	"*"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'">"'
db	BC_NUM_PUSH
dq	">"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"!"'
db	BC_NUM_PUSH
dq	"!"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"@"'
db	BC_NUM_PUSH
dq	"@"
db	BC_WORD_INTERP
dq	"bout"
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
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"w,"'
db	BC_NUM_PUSH
dq	"w,"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'"d,"'
db	BC_NUM_PUSH
dq	"d,"
db	BC_WORD_INTERP
dq	"wout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	'","'
db	BC_NUM_PUSH
dq	","
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"name"
db	BC_WORD_INTERP
dq	"movsq"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"num"
db	BC_WORD_INTERP
dq	"lodsq"
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
; 49 89 fb                mov    r11,rdi
db	BC_NUM_PUSH
dq	0x8949
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xFB
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL

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

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"save"
; 56                      push   rsi
db	BC_NUM_PUSH
dq	0x56
db	BC_COMMA_B
; 41 53                   push   r11
db	BC_NUM_PUSH
dq	0x5341
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"restore"
; 41 5b                   pop    r11
db	BC_NUM_PUSH
dq	0x5B41
db	BC_COMMA_W
; 5e                      pop    rsi
db	BC_NUM_PUSH
dq	0x5E
db	BC_COMMA_B
; 4c 89 df                mov    rdi,r11
db	BC_NUM_PUSH
dq	0x894C
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xDF
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
