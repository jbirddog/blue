
FASM ?= $(shell which fasm)

BLUE_BC_ASMS = $(wildcard \
	lib/aarch64/elf/*.bo.asm \
	lib/bc/*.bo.asm \
	lib/bc/view/*.bo.asm \
	lib/bc/view/ansi/*.bo.asm \
	lib/bc/view/prefix/*.bo.asm \
	lib/elf/*.bo.asm \
	lib/x86_64/*.bo.asm \
	blue/*.bo.asm \
	bnc/*.bo.asm \
	viewer/*.bo.asm \
	examples/aarch64/exit/*.bo.asm \
	examples/exit/*.bo.asm \
	examples/helloworld/*.bo.asm \
	examples/readme/*.bo.asm \
	tests/bc/*.bo.asm \
)

BLUE_BC_OBJS = $(BLUE_BC_ASMS:%.bo.asm=obj/%.bo)

BOOTSTRAP = bin/bootstrap
BLUE_IN_BLUE = bin/bib
BLUE = bin/blue
TOOLS = bin/bnc bin/btv

EXAMPLES = \
	bin/examples/exit \
	bin/examples/aarch64/exit \
	bin/examples/helloworld

.PHONY: all clean

all: $(BLUE_BC_OBJS) $(BLUE) $(TOOLS) $(EXAMPLES)

clean:
	rm -rf bin obj

bin:
	mkdir $@

obj/blue.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/blue/defs.bo \
	obj/blue/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/blue/kernel.bo \
	obj/blue/ops.bo \
	obj/lib/bc/lookup.bo \
	obj/blue/main.bo \
	obj/blue/fin.bo \
	obj/lib/elf/fin.res.bo \

obj/bnc.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/viewer/defs.bo \
	obj/viewer/macros.bo \
	obj/lib/bc/view/prefix/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/lib/bc/view/hexnum.bo \
	obj/lib/bc/view/rt.bo \
	obj/lib/bc/view/prefix/rt.bo \
	obj/lib/bc/view/ops.bo \
	obj/lib/bc/lookup.bo \
	obj/viewer/main.bo \
	obj/viewer/fin.bo \
	obj/lib/elf/fin.res.bo \

obj/btv.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/viewer/defs.bo \
	obj/viewer/macros.bo \
	obj/lib/bc/view/ansi/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/lib/bc/view/hexnum.bo \
	obj/lib/bc/view/rt.bo \
	obj/lib/bc/view/ansi/rt.bo \
	obj/lib/bc/view/ops.bo \
	obj/lib/bc/lookup.bo \
	obj/viewer/main.bo \
	obj/viewer/fin.bo \
	obj/lib/elf/fin.res.bo \

obj/examples/exit.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/lib/elf/headers.min.bo \
	obj/examples/exit/exit.bo \
	obj/lib/elf/fin.min.bo \

obj/examples/aarch64/exit.b: \
	obj/lib/elf/headers.min.bo \
	obj/lib/aarch64/elf/headers.min.patch.bo \
	obj/examples/aarch64/exit/exit.bo \
	obj/lib/elf/fin.min.bo \

obj/examples/helloworld.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/lib/elf/headers.min.bo \
	obj/examples/helloworld/helloworld.bo \
	obj/lib/elf/fin.min.bo \

obj/%.bo: %.bo.asm $(FASM) bc.inc
	@mkdir -p "$(@D)"
	$(FASM) $< $@

obj/%.b:
	cat $^ > $@

$(BOOTSTRAP): bootstrap.asm $(FASM) | bin
	$(FASM) $< $@

$(BLUE_IN_BLUE): obj/blue.b $(BOOTSTRAP)
	$(BOOTSTRAP) < $< > $@ && chmod +x $@
	
$(BLUE): obj/blue.b $(BLUE_IN_BLUE)
	$(BLUE_IN_BLUE) < $< > $@ && chmod +x $@

bin/%: obj/%.b $(BLUE)
	@mkdir -p "$(@D)"
	$(BLUE) < $< > $@ && chmod +x $@
