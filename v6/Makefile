
FASM2 = ../fasm2/fasm2

BLUE_BC_ASMS = $(wildcard *.bo.asm)
BLUE_BC_OBJS = $(ONEX_BC_ASMS:%.bo.asm=obj/%.bo)

BLUE = bin/blue
TOOLS = bin/btv

BTV_OBJS = \
	obj/x8664.bo \
	obj/x8664.linux.bo \
	obj/btv.macros.bo \
	obj/elf.bo \
	obj/btv.bo \
	obj/elf.fin.bo

.PHONY: all clean

all: $(BLUE) $(TOOLS) obj/btv.test.bo

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(BLUE): blue.asm $(FASM2) | bin
	$(FASM2) $< $@

obj/%.bo: %.bo.asm $(FASM2) b.inc | obj
	$(FASM2) $< $@

obj/btv.b: $(BTV_OBJS) | obj
	cat $^ > $@
	
bin/%: obj/%.b $(BLUE) | bin
	 $(BLUE) < $< > $@ && chmod +x $@

