
gen-ops-tbl:
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" opcodes.inc > ops.tbl

.PHONY: gen-ops-tbl
