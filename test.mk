
TESTS := \
	code_buffer_test \
	parser_test \
	elf_test \
	elf_test_hello_world

$(TESTS):
	echo "Testing $@... " && \
	make WHAT=$@ compile run && \
	rm -f $@ && \
	echo ""

tests: $(TESTS)
	rm -f elf_test_hello_world.out

tests-watch:
	watch -d make tests

.PHONY: tests tests-watch $(TESTS)
