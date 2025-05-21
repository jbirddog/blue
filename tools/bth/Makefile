BLASM = ../../lang/blasm/blasm

BTH_INC = bth.inc
OPS = ops_low.bla ops_high.bla
OP_OBJS = $(OPS:%.bla=obj/%.bs0)
OP_TBLS = $(OPS:%.bla=%.tbl)

.PHONY: all clean

all: bth.inc $(OP_OBJS)

clean:
	rm -rf bin obj $(OP_TBLS)

bin obj:
	mkdir $@

ops_%.tbl: ops_%.bla
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

$(BTH_INC): $(OP_TBLS) $(BTH_INC).tmpl $(BTH_INC).sh
	./$(BTH_INC).sh > $@

obj/%.bs0: %.bla | obj
	$(BLASM) -n $< $@
	
