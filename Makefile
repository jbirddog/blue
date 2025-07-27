
FASM ?= $(shell which fasm)

BLUE_BC_ASMS = $(wildcard \
	*.bo.asm \
	lib/elf/*.bo.asm \
	lib/x86_64/*.bo.asm \
	btv/*.bo.asm \
)

BLUE_BC_OBJS = $(BLUE_BC_ASMS:%.bo.asm=obj/%.bo)

BLUE = bin/blue
TOOLS = bin/btv

BTV_OBJS = \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/btv/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/hexnum.bo \
	obj/btv/btv.bo \
	obj/elf.fin.bo

.PHONY: all clean

all: $(BLUE) $(BLUE_BC_OBJS) $(TOOLS)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@

$(BLUE): blue.asm $(FASM) | bin
	$(FASM) $< $@

obj/%.bo: %.bo.asm $(FASM) b.inc | obj
	@mkdir -p "$(@D)"
	$(FASM) $< $@

obj/btv.b: $(BTV_OBJS) | obj
	cat $^ > $@
	
bin/%: obj/%.b $(BLUE) | bin
	 $(BLUE) < $< > $@ && chmod +x $@

