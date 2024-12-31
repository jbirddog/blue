
all: demo.bs0 blue
	./blue < demo.bs0 > demo && chmod +x demo

demo.bs0: demo.bs1
	grep -v "#" $< | xxd -p -r > $@

blue: blue.asm
	fasm $<
