include common.mk

INCS = $(wildcard *.inc)

TESTS = $(wildcard test/*.bla)
TEST_OBJS = $(TESTS:test/%.bla=obj/test_%.bs0)

README = README.md

GEN_FILES = $(BLUEVM_OPS_TBL) $(README)

LANGS = lang/blasm
TOOLS = tools/bth

.PHONY: all clean $(LANGS) $(TOOLS)

all: $(BLUEVM) \
	$(GEN_FILES) \
	$(LANGS) \
	$(TOOLS) \
	$(TEST_OBJS)

clean: $(TOOLS)
	rm -rf bin obj $(GEN_FILES)

bin obj:
	mkdir $@

$(BLUEVM): bluevm.asm $(INCS) $(FASM2) | bin
	$(FASM2) $< $@

$(BLUEVM_OPS_TBL): $(BLUEVM_OPS_INC)
	$(SED_TBL) $< > $@

$(LANGS) $(TOOLS):
	$(MAKE) -C $@ $(MAKECMDGOALS) || exit

obj/test_%.bs0: test/%.bla $(BLASM) $(BTH) | obj
	$(BLASM) -n $< $@ && $(BTH) < $@
	
$(README): $(README).sh $(README).tmpl $(BLUEVM_OPS_TBL)
	./$< > $@
	
scratch: scratch.asm $(FASM2)
	$(FASM2) $< $@
