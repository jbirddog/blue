BLASM = lang/blasm/blasm
BLUEVM = bin/bluevm
FASM2 = fasm2/fasm2
FASMG = fasm2/fasmg.x64

INCS = $(wildcard *.inc)

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)
TEST_DEPS = $(BLUEVM) $(BLASM) $(FASMG)

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)

GEN_FILES = ops.tbl README.md lang/blasm/blasm.inc

all: $(BLUEVM) $(GEN_FILES) $(TEST_OBJS) $(BLASM_EXAMPLE_OBJS)

$(BLUEVM): bluevm.asm $(INCS) $(FASM2) | bin
	$(FASM2) $< $@

$(BLASM): $(BLASM).inc
	touch $@
	
obj/test_%.bs0: tests/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(BLUEVM) < $@

obj/blasm_%.bs0: lang/blasm/examples/%.bla $(TEST_DEPS) | obj
	$(BLASM) -n $< $@ && $(BLUEVM) < $@

bin obj:
	mkdir $@

ops.tbl: ops.inc
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

lang/blasm/blasm.inc: ops.tbl lang/blasm/blasm.inc.tmpl lang/blasm/blasm.inc.sh
	./lang/blasm/blasm.inc.sh > ./lang/blasm/blasm.inc
	
README.md: ops.tbl README.md.tmpl README.sh
	./README.sh > README.md

.PHONY: clean

clean:
	rm -rf bin obj $(GEN_FILES)
