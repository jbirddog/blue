
all: bootstrap.bin v3
	./v3 < bootstrap.bin > out.bin

bootstrap.bin: bootstrap.xxd
	xxd -p -r < $< > $@

v3: v3.asm
	fasm $<
