BLASM = lang/blasm/blasm

BLUEVM = bin/bluevm
FASM2 = fasm2/fasm2

INCS = $(wildcard *.inc)

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)

GEN_FILES = ops.tbl README.md lang/blasm/blasm.inc

all: vm $(GEN_FILES) test example

bluevm.asm: $(INCS)

bin/%: %.asm | bin
	$(FASM2) $^ $@

obj/test_%.bs0: tests/%.bla | obj
	$(BLASM) -n $^ $@
	$(BLUEVM) < $@

obj/blasm_%.bs0: lang/blasm/examples/%.bla | obj
	$(BLASM) -n $^ $@
	$(BLUEVM) < $@

bin obj:
	mkdir $@

ops.tbl: opcodes.inc
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

lang/blasm/blasm.inc: ops.tbl lang/blasm/blasm.inc.tmpl lang/blasm/blasm.inc.sh
	./lang/blasm/blasm.inc.sh > ./lang/blasm/blasm.inc
	
README.md: ops.tbl README.md.tmpl README.sh
	./README.sh > README.md

.PHONY: clean vm test example

clean:
	rm -rf bin obj $(GEN_FILES)

vm: $(BLUEVM)
test: $(TEST_OBJS)
example: $(BLASM_EXAMPLE_OBJS)

