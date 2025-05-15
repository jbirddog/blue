BLASM = lang/blasm/blasm

BLUEVM = bin/bluevm
FASM2 = fasm2/fasm2

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)


all: vm ops.md README.md test example

vm: $(BLUEVM)
test: $(TEST_OBJS)
example: $(BLASM_EXAMPLE_OBJS)

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

clean:
	rm -rf bin obj $(GEN_FILES)

.PHONY: clean vm test example

include gen.mk
