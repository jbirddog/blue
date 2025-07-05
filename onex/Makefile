INCS = $(wildcard *.inc)

FASM2 = ../fasm2/fasm2
ONEX = bin/onex

ONEX_BC_ASMS = $(wildcard *.1x.asm)
ONEX_BC_OBJS = $(ONEX_BC_ASMS:%.1x.asm=obj/%.1x)

.PHONY: all clean

all: $(ONEX) $(ONEX_BC_OBJS)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(ONEX): onex.asm $(INCS) $(FASM2) | bin
	$(FASM2) $< $@

obj/%.1x: %.1x.asm $(FASM2) | obj
	$(FASM2) $< $@
