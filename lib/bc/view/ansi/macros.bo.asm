include "bc.inc"

db	BC_WORD_DEFINE
dq	"red"
db	BC_NUM_PUSH
db	0x1B, "[31", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"green"
db	BC_NUM_PUSH
db	0x1B, "[32", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"yellow"
db	BC_NUM_PUSH
db	0x1B, "[33", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"magenta"
db	BC_NUM_PUSH
db	0x1B, "[35", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"cyan"
db	BC_NUM_PUSH
db	0x1B, "[36", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"white"
db	BC_NUM_PUSH
db	0x1B, "[37", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_DSP_NL

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

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"reset"
db	BC_NUM_PUSH
db	0x1B, "[0m", 0, 0, 0, 0
db	BC_WORD_INTERP
dq	"dout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"++"
db	BC_NUM_PUSH
dq	";"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"shows"
db	BC_WORD_INTERP
dq	"++"
db	BC_WORD_INTERP
dq	"bold"
db	BC_NUM_PUSH
dq	"m"
db	BC_WORD_INTERP
dq	"bout"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
