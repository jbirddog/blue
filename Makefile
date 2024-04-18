BLUE := blue
DEMO := demo

all: build link run
	@true

build:
	nasm -felf64 $(BLUE).asm -l $(BLUE).lst

link:
	ld -o $(BLUE) $(BLUE).o

run:
	./$(BLUE)

dis-out:
	ndisasm -b64 out.bin

dis: dis-out
	@true

build-demo:
	nasm -felf64 $(DEMO).asm

link-demo:
	ld -o $(DEMO) $(DEMO).o

run-demo:
	./$(DEMO)

start: run build-demo link-demo run-demo
	@true

.PHONY:
	build link run \
	build-demo link-demo run-demo \
	dis dis-out \
	start
