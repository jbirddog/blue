
FASM2 = ../fasm2/fasm2
ONEX = bin/onex

ONEX_BC_ASMS = $(wildcard *.1xo.asm)
ONEX_BC_OBJS = $(ONEX_BC_ASMS:%.1xo.asm=obj/%.1xo)

ONEX_OUT_BINS = bin/exit \
	bin/hello

.PHONY: all clean

all: $(ONEX) $(ONEX_BC_OBJS) $(ONEX_OUT_BINS)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(ONEX): onex.asm $(FASM2) | bin
	$(FASM2) $< $@

obj/%.1xo: %.1xo.asm $(FASM2) bc.inc | obj
	$(FASM2) $< $@

obj/exit.1x: obj/elf.1xo obj/exit.1xo obj/elf.fin.1xo | obj
	cat $^ > $@
	
bin/exit: obj/exit.1x $(ONEX) | bin
	 $(ONEX) < $< > $@ && chmod +x $@

obj/hello.1x: obj/hello.macros.1xo obj/elf.1xo obj/hello.1xo obj/elf.fin.1xo | obj
	cat $^ > $@
	
bin/hello: obj/hello.1x $(ONEX) | bin
	 $(ONEX) < $< > $@ && chmod +x $@

