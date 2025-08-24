include "bc.inc"

db	BC_WORD_DEFINE
dq	"eax"
db	BC_NUM_PUSH
dq	0x00
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"edi"
db	BC_NUM_PUSH
dq	0x07
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"/0"
db	BC_NUM_PUSH
dq	0xC0
db	BC_OR
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"/r"
db	BC_NUM_PUSH
dq	0x03
db	BC_SHL
db	BC_OR
db	BC_WORD_INTERP
dq	"/0"
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
dq	"syscall"
db	BC_NUM_PUSH
dq	0x050F
db	BC_COMMA_W
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"!0"
db	BC_DUP
db	BC_WORD_INTERP
dq	"xor"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"eax!"
db	BC_NUM_PUSH
dq	0xB8
db	BC_COMMA_B
db	BC_COMMA_D
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"bye"
db	BC_WORD_INTERP
dq	"edi"
db	BC_WORD_INTERP
dq	"!0"

db	BC_WORD_DEFINE
dq	"exit"
db	BC_NUM_PUSH
dq	0x3C
db	BC_WORD_INTERP
dq	"eax!"
db	BC_WORD_INTERP
dq	"syscall"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL

db	BC_WORD_CCALL
dq	"bye"
