BASE_DIR = ../..

include $(BASE_DIR)/common.mk

BLUEVM_NOEXT = obj/bluevm_noext

BTH = bin/bth
BTH_INC = bth.inc

OPS = ops_internal.bla ops_tap.bla
OP_OBJS = $(OPS:%.bla=obj/%.bs0)
OP_TBLS = $(OPS:%.bla=%.tbl)

TESTS = $(wildcard test/*.bla)
TEST_OBJS = $(TESTS:test/%.bla=obj/test_%.bs0)

GEN_FILES = $(BTH_INC) $(OP_TBLS) $(README)

.PHONY: all clean test

all: $(BTH) $(GEN_FILES) $(TEST_OBJS) test

clean:
	rm -rf bin obj $(GEN_FILES)

bin obj:
	mkdir $@

$(BLUEVM_NOEXT): $(BLUEVM) | obj
	$(DD) if=$(BLUEVM) of=$@ count=3

ops_%.tbl: ops_%.bla
	$(SED_TBL) $< > $@

$(BTH_INC): $(BTH_INC).sh $(BTH_INC).tmpl $(OP_TBLS)
	./$< > $@

obj/%.bs0: %.bla $(BTH_INC) | obj
	$(BLASM) -n $< $@

$(BTH): $(BLUEVM_NOEXT) $(OP_OBJS) obj/bth.bs0 | bin
	cat $^ > $@ && chmod +x $@

obj/test_%.bs0: test/%.bla $(BTH) | obj
	$(BLASM) -n $< $@

test:
	$(PROVE) obj/test_*
	
$(README): $(README).sh $(README).tmpl $(OP_TBLS)
	./$< > $@
