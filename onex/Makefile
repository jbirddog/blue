
FASM2 = ../fasm2/fasm2

BLUE_BC_ASMS = $(wildcard *.1xo.asm)
BLUE_BC_OBJS = $(ONEX_BC_ASMS:%.1xo.asm=obj/%.1xo)

BLUE = bin/blue
TOOLS = bin/btv

.PHONY: all clean

all: $(BLUE) $(TOOLS)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(BLUE): blue.asm $(FASM2) | bin
	$(FASM2) $< $@

obj/%.1xo: %.1xo.asm $(FASM2) b.inc | obj
	$(FASM2) $< $@

obj/btv.1x: obj/elf.1xo obj/btv.1xo obj/elf.fin.1xo | obj
	cat $^ > $@
	
bin/%: obj/%.1x $(BLUE) | bin
	 $(BLUE) < $< > $@ && chmod +x $@

