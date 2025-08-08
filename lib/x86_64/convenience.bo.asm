include "bc.inc"

db	BC_WORD_DEFINE
dq	"edx="
db	BC_NUM_PUSH
dq	0xBA
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rdx="
db	BC_NUM_PUSH
dq	0xBA48
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rbx="
db	BC_NUM_PUSH
dq	0xBB48
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rsi="
db	BC_NUM_PUSH
dq	0xBE48
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rdi="
db	BC_NUM_PUSH
dq	0xBF48
db	BC_COMMA_W
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"al!"
db	BC_NUM_PUSH
dq	0xB0
db	BC_COMMA_B
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"ax!"
db	BC_NUM_PUSH
dq	0xB866
db	BC_COMMA_W
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"eax!"
db	BC_NUM_PUSH
dq	0xB8
db	BC_COMMA_B
db	BC_COMMA_D
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edx!"
db	BC_WORD_INTERP
dq	"edx="
db	BC_COMMA_D
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rsi!"
db	BC_WORD_INTERP
dq	"rsi="
db	BC_COMMA
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"!0"
db	BC_DUP
db	BC_WORD_INTERP
dq	"xor"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"!1"
db	BC_DUP
db	BC_WORD_INTERP
dq	"!0"
db	BC_WORD_INTERP
dq	"inc"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
