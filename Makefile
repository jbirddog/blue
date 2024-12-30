
all: bootstrap.bin v3
	./v3 < bootstrap.bin

bootstrap.bin: bootstrap.xxd
	xxd -p -r < $< > $@

v3: v3.asm
	fasm $<
