
FASM ?= $(shell which fasm)

BLUE_BC_ASMS = $(wildcard \
	lib/bc/view/*.bo.asm \
	lib/bc/view/ansi/*.bo.asm \
	lib/bc/view/prefix/*.bo.asm \
	lib/elf/*.bo.asm \
	lib/x86_64/*.bo.asm \
	blue/*.bo.asm \
	bnc/*.bo.asm \
	btv/*.bo.asm \
	examples/exit/*.bo.asm \
	examples/helloworld/*.bo.asm \
	tests/bc/*.bo.asm \
)

BLUE_BC_OBJS = $(BLUE_BC_ASMS:%.bo.asm=obj/%.bo)

BLUE = bin/blue
BLUE_IN_BLUE = bin/bib
TOOLS = bin/bnc bin/btv

EXAMPLES = \
	bin/examples/exit \
	bin/examples/helloworld

.PHONY: all clean

all: $(BLUE) $(BLUE_BC_OBJS) $(BLUE_IN_BLUE) $(TOOLS) $(EXAMPLES)

clean:
	rm -rf bin obj

bin:
	mkdir $@

$(BLUE): blue.asm $(FASM) | bin
	$(FASM) $< $@

obj/bib.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/blue/defs.bo \
	obj/blue/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/blue/kernel.bo \
	obj/blue/ops.bo \
	obj/blue/lookup.bo \
	obj/blue/main.bo \
	obj/blue/fin.bo \

obj/bnc.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/btv/dispatch.bo \
	obj/btv/macros.bo \
	obj/lib/bc/view/prefix/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/lib/bc/view/hexnum.bo \
	obj/lib/bc/view/rt.bo \
	obj/lib/bc/view/prefix/rt.bo \
	obj/btv/ops.bo \
	obj/blue/lookup.bo \
	obj/btv/main.bo \
	obj/btv/fin.bo \
	obj/btv/elf.fin.bo

obj/btv.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/btv/dispatch.bo \
	obj/btv/macros.bo \
	obj/lib/bc/view/ansi/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/lib/bc/view/hexnum.bo \
	obj/lib/bc/view/rt.bo \
	obj/lib/bc/view/ansi/rt.bo \
	obj/btv/ops.bo \
	obj/blue/lookup.bo \
	obj/btv/main.bo \
	obj/btv/fin.bo \
	obj/btv/elf.fin.bo

obj/examples/exit.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/lib/elf/headers.min.bo \
	obj/examples/exit/exit.bo \
	obj/lib/elf/fin.min.bo

obj/examples/helloworld.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/lib/elf/headers.min.bo \
	obj/examples/helloworld/helloworld.bo \
	obj/lib/elf/fin.min.bo

obj/%.bo: %.bo.asm $(FASM) bc.inc
	@mkdir -p "$(@D)"
	$(FASM) $< $@

obj/%.b:
	cat $^ > $@
	
bin/%: obj/%.b $(BLUE)
	@mkdir -p "$(@D)"
	$(BLUE) < $< > $@ && chmod +x $@

