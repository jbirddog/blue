BASE_DIR = ../..

include $(BASE_DIR)/common.mk

BLASM_INC = $(BLASM).inc

EXAMPLES = $(wildcard examples/*.bla)
EXAMPLE_OBJS = $(EXAMPLES:examples/%.bla=obj/example_%.bs0)

GEN_FILES = $(BLASM_INC) $(README)

.PHONY: all clean

all: $(GEN_FILES) $(EXAMPLE_OBJS)

clean:
	rm -rf obj $(GEN_FILES)

obj:
	mkdir $@

$(BLASM): $(BLASM).inc $(FASMG) 

obj/example_%.bs0: examples/%.bla $(BLASM) $(BLUEVM) | obj
	$(BLASM) -n $< $@ && $(BLUEVM) < $@

$(BLASM_INC): $(BLASM_INC).sh $(BLASM_INC).tmpl $(BLUEVM_OPS_TBL)
	./$< > $@

$(README): $(README).sh $(README).tmpl
	./$< > $@
