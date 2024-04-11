all: build link run
	@true

build:
	nasm -felf64 driver.asm -l driver.lst

link:
	ld driver.o

run:
	./a.out

.PHONY:
	build link run
