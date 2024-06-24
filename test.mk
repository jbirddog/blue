
TESTS := \
	code_buffer_test \
	data_stack_test \
	to_number_test \
	parser_test \
	dictionary_test \
	kernel_test \
	elf_test \
	elf_test_hello_world

$(TESTS):
	@echo "Testing $@... " && \
	make WHAT=$@ compile run && \
	rm -f $@ && \
	echo ""

tests: $(TESTS)
	rm -f elf_test_hello_world.out

.PHONY: tests $(TESTS)
