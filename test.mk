
TESTS := \
	elf_test \
	elf_test_hello_world

$(TESTS):
	echo "Testing $@... " && make WHAT=$@ compile run && echo ""

tests: $(TESTS)
	@/bin/true

.PHONY: tests $(TESTS)
