BASE_DIR = ../..

include $(BASE_DIR)/common.mk

BLASM_INC = $(BLASM).inc
README = README.md

EXAMPLES = $(wildcard examples/*.bla)
EXAMPLE_OBJS = $(BLASM_EXAMPLES:examples/%.bla=obj/example_%.bs0)

GEN_FILES = $(BLASM_INC) $(README)

.PHONY: all clean

all: $(GEN_FILES) $(EXAMPLE_OBJS)

clean:
	rm -rf obj $(GEN_FILES)

obj:
	mkdir $@

$(BLASM): $(BLASM).inc

obj/example_%.bs0: examples/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(BLUEVM) < $@

$(BLASM_INC): $(BLASM_INC).sh $(BLASM_INC).tmpl $(BLUEVM_OPS_TBL)
	./$< > $@

$(README): $(README).sh $(README).tmpl
	./$< > $@
