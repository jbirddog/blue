include "b.inc"

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
db	BC_WORD_INTERP
dq	"rdx="
db	BC_WORD_DEFINE
dq	"optbl"
db	BC_NUM_COMP
dq	0x00
db	BC_NUM_PUSH
dq	0x24FF
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xC2
db	BC_COMMA_B
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
dq	"initsd"
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
dq	"ds!"
; 49 89 45 00             mov    QWORD PTR [r13+0x0],rax
db	BC_NUM_PUSH
dq	0x00458949
db	BC_COMMA_D
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"ds@"
; 49 8b 45 00             mov    rax,QWORD PTR [r13+0x0]
db	BC_NUM_PUSH
dq	0x00458B49
db	BC_COMMA_D
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"ds++"
; 49 83 c5 08             add    r13,0x8
db	BC_NUM_PUSH
dq	0x08C58349
db	BC_COMMA_D
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"ds--"
; 49 83 ed 08             sub    r13,0x8
db	BC_NUM_PUSH
dq	0x08ED8349
db	BC_COMMA_D
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"ds&mask"
; 49 83 e5 7f             and    r13,0x7f
db	BC_NUM_PUSH
dq	0x8349
db	BC_COMMA_W
db	BC_NUM_PUSH
dq	0xE5
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"dsmask"
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
