BIN = bin
OBJ = obj

FASM2 ?= fasm2/fasm2
BLUEVM = $(BIN)/bluevm

TESTS = $(wildcard tests/*.bla)
TEST_OBJS = $(TESTS:tests/%.bla=obj/test_%.bs0)

all: $(BLUEVM) $(TEST_OBJS)

bin/%: %.asm | $(BIN)
	$(FASM2) $^ $@

obj/test_%.bs0: tests/%.bla | obj
	./lang/blasm/blasm -n $^ $@

$(BIN) $(OBJ):
	mkdir $@

clean:
	rm -rf $(BIN) $(OBJ)

.PHONY:
	clean test
