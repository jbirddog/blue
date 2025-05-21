
BASE_DIR ?= .

BLASM = $(BASE_DIR)/lang/blasm/blasm
BLUEVM = $(BASE_DIR)/bin/bluevm
BTH = $(BASE_DIR)/tools/bth/bin/bth
FASM2 = $(BASE_DIR)/fasm2/fasm2
FASMG = $(BASE_DIR)/fasm2/fasmg.x64

BLUEVM_OPS_INC = $(BASE_DIR)/ops_vm.inc
BLUEVM_OPS_TBL = $(BASE_DIR)/ops_vm.tbl

DD = dd status=none bs=1024

SED_TBL = sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p"
