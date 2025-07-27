
FASM ?= $(shell which fasm)

BLUE_BC_ASMS = $(wildcard \
	lib/elf/*.bo.asm \
	lib/x86_64/*.bo.asm \
	btv/*.bo.asm \
	examples/exit/*.bo.asm \
)

BLUE_BC_OBJS = $(BLUE_BC_ASMS:%.bo.asm=obj/%.bo)

BLUE = bin/blue
TOOLS = bin/btv
EXAMPLES = bin/examples/exit

BTV_OBJS = \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/btv/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/btv/hexnum.bo \
	obj/btv/btv.bo \
	obj/btv/elf.fin.bo

EXAMPLES_EXIT_OBJS = \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/lib/elf/headers.min.bo \
	obj/examples/exit/exit.bo \
	obj/lib/elf/fin.min.bo

.PHONY: all clean

all: $(BLUE) $(BLUE_BC_OBJS) $(TOOLS) $(EXAMPLES)

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

obj/examples/exit.b: $(EXAMPLES_EXIT_OBJS) | obj
	cat $^ > $@
	
bin/%: obj/%.b $(BLUE) | bin
	@mkdir -p "$(@D)"
	$(BLUE) < $< > $@ && chmod +x $@

