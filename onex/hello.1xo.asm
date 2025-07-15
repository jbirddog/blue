include "bc.inc"

;bf 01 00 00 00          mov    edi,0x1
db	BC_NUM_EXEC
dq	0xBF
db	BC_WORD_EXEC
dq	"b,"
db	BC_NUM_EXEC
dq	0x01
db	BC_WORD_EXEC
dq	"d,"

db	BC_ED_NL

; 48 be [qword]          movabs	rsi,buf
db	BC_NUM_EXEC
dq	0xBE48
db	BC_WORD_EXEC
dq	"w,"
db	BC_WORD_DEFINE
dq	"buf"
db	BC_NUM_COMP
dq	0x00

db	BC_ED_NL

; ba [dword]              mov    edx,bufsz
db	BC_NUM_EXEC
dq	0xBA
db	BC_WORD_EXEC
dq	"b,"
db	BC_WORD_DEFINE
dq	"bufsz"
db	BC_NUM_EXEC
dq	0x00
db	BC_WORD_EXEC
dq	"d,"

db	BC_ED_NL

db	BC_WORD_INTERP
dq	"write"

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"bye"
db	BC_WORD_INTERP
dq	"xoredi"
db	BC_WORD_INTERP
dq	"exit"
db	BC_WORD_END

db	BC_ED_NL
db	BC_ED_NL

db	BC_WORD_DEFINE
dq	"msg"
db	BC_NUM_COMP
dq	"Hello, w"
db	BC_NUM_COMP
db	"orld!  ", 10

db	BC_ED_NL

db	BC_WORD_RADDR
dq	"msg"
db	BC_WORD_CADDR
dq	"buf"
db	BC_WORD_EXEC
dq	"!"

db	BC_ED_NL

db	BC_WORD_EXEC
dq	"$"
db	BC_WORD_CADDR
dq	"msg"
db	BC_WORD_EXEC
dq	"-"
db	BC_WORD_CADDR
dq	"bufsz"
db	BC_WORD_EXEC
dq	"d!"

db	BC_ED_NL
