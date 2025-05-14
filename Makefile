FASM2 ?= fasm2/fasm2

all: vm

vm:
	$(FASM2) bluevm.asm bin/bluevm

.PHONY:
	vm
