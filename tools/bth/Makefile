BASE_DIR = ../..

include $(BASE_DIR)/common.mk

BLUEVM_NOEXT = obj/bluevm_noext

BTH = bin/bth
BTH_INC = bth.inc
OPS = ops_low.bla ops_high.bla
OP_OBJS = $(OPS:%.bla=obj/%.bs0)
OP_TBLS = $(OPS:%.bla=%.tbl)

TESTS = $(wildcard test/*.bla)
TEST_OBJS = $(TESTS:test/%.bla=obj/test_%.bs0)

GEN_FILES = $(BTH_INC) $(OP_TBLS)

.PHONY: all clean

all: $(BTH) $(TEST_OBJS)

clean:
	rm -rf bin obj $(GEN_FILES)

bin obj:
	mkdir $@

$(BLUEVM_NOEXT): $(BLUEVM) | obj
	$(DD) if=$(BLUEVM) of=$@ count=3

ops_%.tbl: ops_%.bla
	$(SED_TBL) $< > $@

$(BTH_INC): $(OP_TBLS) $(BTH_INC).tmpl $(BTH_INC).sh
	./$(BTH_INC).sh > $@

obj/%.bs0: %.bla $(BTH_INC) | obj
	$(BLASM) -n $< $@

obj/blk_%.bs0: $(BLUEVM) | obj
	$(DD) if=$(BLUEVM) of=$@ skip=$* count=1
	
$(BTH): $(BLUEVM_NOEXT) $(OP_OBJS) obj/blk_5.bs0 | bin
	cat $^ > $@ && chmod +x $@

obj/test_%.bs0: test/%.bla $(BTH) | obj
	$(BLASM) -n $< $@ && $(BTH) < $@

