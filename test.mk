
TESTS := \
	code_buffer_test \
	elf_test \
	elf_test_hello_world

$(TESTS):
	echo "Testing $@... " && make WHAT=$@ compile run && echo ""

tests: $(TESTS)
	@/bin/true

tests-watch:
	watch -d make tests

.PHONY: tests tests-watch $(TESTS)
