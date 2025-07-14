include "bc.inc"

;
;	120 byte minimal elf header. format borrowed from an executable built with fasm2 using:
;
;	```
;	format ELF64 executable 3
;	segment readable writeable executable
;	entry $
;	```
;
;	entry - main entry point - qword at +0x18 (0x400000 + 120 + code offset)
;	elfbsz - size in binary - qword at +0x60
;	elfmsz - size in memory - qword at +0x68

;
;	0000000 457f 464c 0102 0301 0000 0000 0000 0000
;
db	BC_WORD_DEFINE
dq	"elfhdrs"
db	BC_WORD_EXEC
dq	"$"
db	BC_WORD_CADDR
dq	"$$"
db	BC_WORD_EXEC
dq	"!"

db	BC_ED_NL

db	BC_NUM_COMP
dq	0x0301'0102'464C'457F
db	BC_NUM_COMP
dq	0x00

;
;	0000010 0002 003e 0001 0000 0078 0040 0000 0000
;
db	BC_NUM_COMP
dq	0x0000'0001'003E'0002

db	BC_WORD_DEFINE
dq	"entry"
db	BC_NUM_COMP
dq	0x0000'0000'0040'0078

db	BC_ED_NL

;
;	0000020 0040 0000 0000 0000 0000 0000 0000 0000
;
db	BC_NUM_COMP
dq	0x0000'0000'0000'0040
db	BC_NUM_COMP
dq	0x00

;
;	0000030 0000 0000 0040 0038 0001 0040 0000 0000
;
db	BC_NUM_COMP
dq	0x0038'0040'0000'0000
db	BC_NUM_COMP
dq	0x0000'0000'0040'0001

db	BC_ED_NL

;
;	0000040 0001 0000 0007 0000 0000 0000 0000 0000
;
db	BC_NUM_COMP
dq	0x0000'0007'0000'0001
db	BC_NUM_COMP
dq	0x00

;
;	0000050 0000 0040 0000 0000 0000 0040 0000 0000
;
db	BC_WORD_CADDR
dq	"org"
db	BC_WORD_EXEC
dq	"@"
db	BC_WORD_EXEC
dq	"dup"
db	BC_WORD_EXEC
dq	","
db	BC_WORD_EXEC
dq	","

db	BC_ED_NL

;
;	0000060 0081 0000 0000 0000 0081 0000 0000 0000
;
db	BC_WORD_DEFINE
dq	"elfbsz"
db	BC_NUM_COMP
dq	0x00

db	BC_WORD_DEFINE
dq	"elfmsz"
db	BC_NUM_COMP
dq	0x00

;
;	0000070 1000 0000 0000 0000
;
db	BC_NUM_COMP
dq	0x0000'0000'0000'1000

db	BC_ED_NL
db	BC_ED_NL
