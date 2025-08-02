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

