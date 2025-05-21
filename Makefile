include common.mk

BLUEVM_NOIB = $(BLUEVM)_noib

INCS = $(wildcard *.inc)

TEST_OPS = $(wildcard tests/ops/*.bla)
TEST_OP_OBJS = $(TEST_OPS:tests/ops/%.bla=obj/test_ops_%.bs0)
TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)
TEST_DEPS = $(FASMG) $(BLUEVM) $(BLASM)
TEST_RUNNER = bin/test_runner

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)

GEN_FILES = ops_vm.tbl README.md lang/blasm/blasm.inc tests/ops/low.tbl tests/ops.inc
BLKS = obj/blk_5.bs0
PATCHED_BINS = bin/hello_world

TOOLS = tools/bth

.PHONY: all clean $(TOOLS)

all: $(BLUEVM) \
	$(GEN_FILES) \
	$(BLKS) \
	$(TOOLS) \
	$(TEST_OP_OBJS) \
	$(TEST_RUNNER) \
	$(TEST_OBJS) \
	$(BLASM_EXAMPLE_OBJS) \
	$(PATCHED_BINS)

clean: $(TOOLS)
	rm -rf bin obj $(GEN_FILES)

bin obj:
	mkdir $@

$(BLUEVM): bluevm.asm $(INCS) $(FASM2) | bin
	$(FASM2) $< $@

$(BLUEVM_NOEXT): $(BLUEVM)
	$(DD) if=$(BLUEVM) of=$@ count=3

$(BLUEVM_NOIB): $(BLUEVM)
	$(DD) if=$(BLUEVM) of=$@ count=5

$(BLASM): $(BLASM).inc

$(TOOLS):
	$(MAKE) -C $@ $(MAKECMDGOALS) || exit

obj/blk_%.bs0: $(BLUEVM) $(BLASM) | obj
	$(DD) if=$(BLUEVM) of=$@ skip=$* count=1
	
obj/test_ops_%.bs0: tests/ops/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@

$(TEST_RUNNER): $(BLUEVM_NOEXT) obj/test_ops_low.bs0 obj/test_ops_high.bs0 obj/blk_5.bs0
	cat $^ > $@ && chmod +x $@
	
obj/test_%.bs0: tests/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(TEST_RUNNER) < $@

obj/blasm_%.bs0: lang/blasm/examples/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(TEST_RUNNER) < $@
	
bin/hello_world: $(BLUEVM_NOIB) obj/blasm_hello_world.bs0
	cat $^ > $@ && chmod +x $@ && ./$@

ops_vm.tbl: ops_vm.inc
tests/ops/low.tbl: tests/ops/low.bla

ops_vm.tbl tests/ops/low.tbl:
	$(SED_TBL) $< > $@

tests/ops.inc: tests/ops/low.tbl tests/ops.inc.tmpl tests/ops.inc.sh
	./tests/ops.inc.sh > ./tests/ops.inc

lang/blasm/blasm.inc: ops_vm.tbl lang/blasm/blasm.inc.tmpl lang/blasm/blasm.inc.sh
	./lang/blasm/blasm.inc.sh > ./lang/blasm/blasm.inc
	
README.md: ops_vm.tbl README.md.tmpl README.sh
	./README.sh > README.md
	
scratch: scratch.asm $(FASM2)
	$(FASM2) $< $@
