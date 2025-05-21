GEN_FILES = ops_low.tbl ops_high.tbl

all: $(GEN_FILES)

ops_%.tbl: ops_%.bla
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

.PHONY: all
