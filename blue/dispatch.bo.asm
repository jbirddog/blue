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
db	BC_NUM_PUSH
dq	0xC0C524FF
db	BC_COMMA_D
db	BC_WORD_DEFINE
dq	"optbl"
db	BC_NUM_COMP
dq	0x00
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
