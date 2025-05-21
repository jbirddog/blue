
BASE_DIR ?= .

BLASM = $(BASE_DIR)/lang/blasm/blasm
BLUEVM = $(BASE_DIR)/bin/bluevm
BLUEVM_NOEXT = $(BASE_DIR)/$(BLUEVM)_noext
BLUEVM_NOIB = $(BASE_DIR)/$(BLUEVM)_noib
FASM2 = $(BASE_DIR)/fasm2/fasm2
FASMG = $(BASE_DIR)/fasm2/fasmg.x64

DD = dd status=none bs=1024

SED_TBL = sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p"
