include "bc.inc"

db	BC_WORD_DEFINE
dq	"red"
db	BC_NUM_PUSH
dq	":"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"green"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"yellow"
db	BC_NUM_PUSH
dq	"#"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"magenta"
db	BC_NUM_PUSH
dq	"@"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"cyan"
db	BC_NUM_PUSH
dq	"~"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"white"
db	BC_NUM_PUSH
dq	"&"
db	BC_WORD_INTERP
dq	"b,"
db	BC_WORD_END

db	BC_DSP_NL

db	BC_WORD_DEFINE
dq	"reset"
db	BC_WORD_END

db	BC_WORD_DEFINE
dq	"shows"
db	BC_WORD_END

db	BC_DSP_NL
db	BC_DSP_NL
