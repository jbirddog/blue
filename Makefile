
all: bootstrap.bin v3
	@true

bootstrap.bin: bootstrap.xxd
	xxd -p -r < $< > $@

v3: v3.asm
	fasm $<
