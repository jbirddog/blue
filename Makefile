BIN = bin
OBJ = obj

BLASM ?= lang/blasm/blasm
BLUEVM ?= $(BIN)/bluevm
FASM2 ?= fasm2/fasm2

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)

all: $(BLUEVM) $(TEST_OBJS)

bin/%: %.asm | $(BIN)
	$(FASM2) $^ $@

obj/test_%.bs0: tests/%.bla | $(OBJ)
	$(BLASM) -n $^ $@
	$(BLUEVM) < $@

$(BIN) $(OBJ):
	mkdir $@

clean:
	rm -rf $(BIN) $(OBJ)

.PHONY:
	clean
