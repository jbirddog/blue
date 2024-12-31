
all: demo.bs0 v3
	./v3 < demo.bs0 > demo && chmod +x demo

demo.bs0: demo.bs1
	grep -v "#" $< | xxd -p -r > $@

v3: v3.asm
	fasm $<
