
FASM ?= $(shell which fasmarm)

ARCH_PREFIX = aarch64-linux-

BOOTSTRAP_ASM = $(ARCH_PREFIX)bootstrap.asm
BOOTSTRAP = $(BOOTSTRAP_ASM:%.asm=bin/%)

.PHONY: all scp

all: $(BOOTSTRAP)

# TODO: common.mk
bin:
	mkdir $@

$(BOOTSTRAP): $(BOOTSTRAP_ASM) $(FASM) | bin
	$(FASM) $< $@

scp: $(BOOTSTRAP)
	scp $(BOOTSTRAP) $(BLUE_AARCH64_HOST):$(BLUE_AARCH64_PATH)
