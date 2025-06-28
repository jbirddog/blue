INCS = $(wildcard *.inc)

FASM2 = ../fasm2/fasm2
ONEX = bin/onex

.PHONY: all clean

all: $(ONEX)

clean:
	rm -rf bin obj

bin obj:
	mkdir $@
	
$(ONEX): onex.asm | bin
	$(FASM2) $< $@
