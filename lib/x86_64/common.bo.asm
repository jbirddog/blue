include "bc.inc"

db	BC_WORD_DEFINE
dq	"rex.w"
db	BC_WORD_INTERP
dq	"rex"
db	BC_WORD_INTERP
dq	".w"
db	BC_OR
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rex.wr"
db	BC_WORD_INTERP
dq	"rex"
db	BC_WORD_INTERP
dq	".w"
db	BC_OR
db	BC_WORD_INTERP
dq	".r"
db	BC_OR
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"rex.b"
db	BC_WORD_INTERP
dq	"rex"
db	BC_WORD_INTERP
dq	".b"
db	BC_OR
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"mov"
db	BC_NUM_PUSH
dq	0x89
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"/r"
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"xor"
db	BC_NUM_PUSH
dq	0x31
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"/r"
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"inc"
db	BC_NUM_PUSH
dq	0xFF
db	BC_COMMA_B
db	BC_WORD_INTERP
dq	"/0"
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"syscall"
db	BC_NUM_PUSH
dq	0x050F
db	BC_COMMA_W
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"lodsb"
db	BC_NUM_PUSH
dq	0xAC
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"lodsq"
db	BC_NUM_PUSH
dq	0xAD48
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"movsq"
db	BC_NUM_PUSH
dq	0xA548
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"stosb"
db	BC_NUM_PUSH
dq	0xAA
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"stosw"
db	BC_NUM_PUSH
dq	0xAB66
db	BC_COMMA_W
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"stosq"
db	BC_WORD_INTERP
dq	"rex.w"

db	BC_WORD_DEFINE
dq	"stosd"
db	BC_NUM_PUSH
dq	0xAB
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"push"
db	BC_NUM_PUSH
dq	0x50
db	BC_ADD
db	BC_COMMA_B
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"pop"
db	BC_NUM_PUSH
dq	0x58
db	BC_ADD
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"xlatb"
db	BC_NUM_PUSH
dq	0xD7
db	BC_COMMA_B
db	BC_WORD_END

db	BC_DSP_NL
