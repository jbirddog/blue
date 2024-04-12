BLUE := blue

all: build link run
	@true

build:
	nasm -felf64 $(BLUE).asm -l $(BLUE).lst

link:
	ld -o $(BLUE) $(BLUE).o

run:
	./$(BLUE)

.PHONY:
	build link run
