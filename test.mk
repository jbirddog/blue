
TESTS := \
	dictionary_test \
	flow_test \
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
