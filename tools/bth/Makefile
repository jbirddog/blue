BASE_DIR = ../..

include $(BASE_DIR)/common.mk

BLUEVM_NOEXT = obj/bluevm_noext

BTH = bin/bth
INTERNAL_INC = internal.inc
TAP_INC = tap.inc

OPS = ops_internal.bla ops_tap.bla
OP_OBJS = $(OPS:%.bla=obj/%.bs0)
OP_TBLS = $(OPS:%.bla=%.tbl)

TESTS = $(wildcard test/*.bla)
TEST_OBJS = $(TESTS:test/%.bla=obj/test_%.bs0)

GEN_FILES = $(INTERNAL_INC) $(TAP_INC) $(OP_TBLS) $(README)

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

$(INTERNAL_INC): $(INTERNAL_INC).sh $(INTERNAL_INC).tmpl $(OP_TBLS)
	./$< > $@

$(TAP_INC): $(TAP_INC).sh $(TAP_INC).tmpl $(OP_TBLS)
	./$< > $@

obj/%.bs0: %.bla $(INTERNAL_INC) | obj
	$(BLASM) -n $< $@

$(BTH): $(BLUEVM_NOEXT) $(OP_OBJS) obj/bth.bs0 | bin
	cat $^ > $@ && chmod +x $@

obj/test_%.bs0: test/%.bla $(BTH) $(TAP_INC) | obj
	$(BLASM) -n $< $@

test:
	$(PROVE) obj/test_*
	
$(README): $(README).sh $(README).tmpl $(OP_TBLS)
	./$< > $@
