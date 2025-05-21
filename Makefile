include common.mk

BLUEVM_NOIB = $(BLUEVM)_noib

INCS = $(wildcard *.inc)

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)
TEST_DEPS = $(FASMG) $(BLUEVM) $(BLASM)

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)

GEN_FILES = ops_vm.tbl README.md lang/blasm/blasm.inc
PATCHED_BINS = bin/hello_world

TOOLS = tools/bth

.PHONY: all clean $(TOOLS)

all: $(BLUEVM) \
	$(GEN_FILES) \
	$(BLKS) \
	$(TOOLS) \
	$(TEST_OBJS) \
	$(BLASM_EXAMPLE_OBJS) \
	$(PATCHED_BINS)

clean: $(TOOLS)
	rm -rf bin obj $(GEN_FILES)

bin obj:
	mkdir $@

$(BLUEVM): bluevm.asm $(INCS) $(FASM2) | bin
	$(FASM2) $< $@

$(BLUEVM_NOIB): $(BLUEVM)
	$(DD) if=$(BLUEVM) of=$@ count=5

$(BLASM): $(BLASM).inc

$(TOOLS):
	$(MAKE) -C $@ $(MAKECMDGOALS) || exit
		
obj/test_%.bs0: tests/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(BTH) < $@

obj/blasm_%.bs0: lang/blasm/examples/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(BTH) < $@
	
bin/hello_world: $(BLUEVM_NOIB) obj/blasm_hello_world.bs0
	cat $^ > $@ && chmod +x $@ && ./$@

ops_vm.tbl: ops_vm.inc
	$(SED_TBL) $< > $@

lang/blasm/blasm.inc: ops_vm.tbl lang/blasm/blasm.inc.tmpl lang/blasm/blasm.inc.sh
	./lang/blasm/blasm.inc.sh > ./lang/blasm/blasm.inc
	
README.md: ops_vm.tbl README.md.tmpl README.sh
	./README.sh > README.md
	
scratch: scratch.asm $(FASM2)
	$(FASM2) $< $@
