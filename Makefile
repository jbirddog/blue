BLASM = lang/blasm/blasm
BLASM_INC = $(BLASM).inc

BLUEVM = bin/bluevm
FASM2 = fasm2/fasm2

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)

BLASM_EXAMPLES = $(wildcard lang/blasm/examples/*.bla)
BLASM_EXAMPLE_OBJS = $(BLASM_EXAMPLES:lang/blasm/examples/%.bla=obj/blasm_%.bs0)

all: $(BLUEVM) $(TEST_OBJS) $(BLASM_EXAMPLE_OBJS)

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
	rm -rf bin obj

.PHONY:
	clean
