OP_TBLS = ops_low.tbl ops_high.tbl

.PHONY: all

all: bth.inc

ops_%.tbl: ops_%.bla
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

bth.inc: $(OP_TBLS) bth.inc.tmpl bth.inc.sh
	./bth.inc.sh > bth.inc
