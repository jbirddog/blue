
FASM ?= $(shell which fasm)

BLUE_BC_ASMS = $(wildcard \
	lib/elf/*.bo.asm \
	lib/x86_64/*.bo.asm \
	blue/*.bo.asm \
	btv/*.bo.asm \
	examples/exit/*.bo.asm \
	examples/helloworld/*.bo.asm \
)

BLUE_BC_OBJS = $(BLUE_BC_ASMS:%.bo.asm=obj/%.bo)

BLUE = bin/blue
TOOLS = bin/btv

EXAMPLES = \
	bin/examples/exit \
	bin/examples/helloworld

.PHONY: all clean

all: $(BLUE) $(BLUE_BC_OBJS) $(TOOLS) $(EXAMPLES)

clean:
	rm -rf bin obj

bin:
	mkdir $@

$(BLUE): blue.asm $(FASM) | bin
	$(FASM) $< $@

obj/btv.b: \
	obj/lib/x86_64/encoding.bo \
	obj/lib/x86_64/common.bo \
	obj/lib/x86_64/convenience.bo \
	obj/lib/x86_64/linux.bo \
	obj/btv/macros.bo \
	obj/lib/elf/headers.min.bo \
	obj/btv/hexnum.bo \
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

obj/%.bo: %.bo.asm $(FASM) b.inc
	@mkdir -p "$(@D)"
	$(FASM) $< $@

obj/%.b:
	cat $^ > $@
	
bin/%: obj/%.b $(BLUE)
	@mkdir -p "$(@D)"
	$(BLUE) < $< > $@ && chmod +x $@

