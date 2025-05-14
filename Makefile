FASM2 ?= fasm2/fasm2

bin/bluevm: bluevm.asm | bin
	$(FASM2) $^ $@

bin:
	mkdir $@

clean:
	rm -rf bin

.PHONY:
	clean
