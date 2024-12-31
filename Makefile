
all: bootstrap.bin v3
	./v3 < bootstrap.bin > out.bin

bootstrap.bin: bootstrap.xxd
	grep -v "# " $< | xxd -p -r > $@

v3: v3.asm
	fasm $<

min: min.asm
	fasm $<
