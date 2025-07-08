
FASM2 = ../fasm2/fasm2
ONEX = bin/onex

ONEX_BC_ASMS = $(wildcard *.1x.asm)
ONEX_BC_OBJS = $(ONEX_BC_ASMS:%.1x.asm=obj/%.1x)

#ONEX_OUT_BINS = $(ONEX_BC_OBJS:obj/%.1x=bin/%)
ONEX_OUT_BINS = bin/exit

.PHONY: all clean

all: $(ONEX) $(ONEX_BC_OBJS) $(ONEX_OUT_BINS)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(ONEX): onex.asm $(FASM2) | bin
	$(FASM2) $< $@

obj/%.1x: %.1x.asm $(FASM2) | obj
	$(FASM2) $< $@

#bin/%: obj/%.1x $(ONEX) | bin
#	$(ONEX) < $< > $@ && chmod +x $@

bin/exit: obj/elf.1x obj/exit.1x $(ONEX) | bin
	cat obj/elf.1x obj/exit.1x | $(ONEX) > $@ && chmod +x $@
