BLASM = ../../lang/blasm/blasm
BLUEVM = ../../bin/bluevm
SED_TBL = sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p"

BTH_INC = bth.inc
OPS = ops_low.bla ops_high.bla
OP_OBJS = $(OPS:%.bla=obj/%.bs0)
OP_TBLS = $(OPS:%.bla=%.tbl)

GEND = $(BTH_INC) $(OP_TBLS)

.PHONY: all clean

all: $(OP_OBJS)

clean:
	rm -rf bin obj $(GEND)

bin obj:
	mkdir $@

ops_%.tbl: ops_%.bla
	$(SED_TBL) $< > $@

$(BTH_INC): $(OP_TBLS) $(BTH_INC).tmpl $(BTH_INC).sh
	./$(BTH_INC).sh > $@

obj/%.bs0: %.bla $(BTH_INC) | obj
	$(BLASM) -n $< $@
	
