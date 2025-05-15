
ops.tbl: opcodes.inc
	sed -rn "s/^op[NB]I?\top_([^,]+), ([0-9]), [^\t]+\t;\t(.*)/\1\t\2\t\3/p" $^ > $@

ops.md: ops.tbl
	awk -v FS='\t' '{printf "| %02x | %s | %s | %s |\n", NR - 1, $$1, $$3, $$4}' ops.tbl > ops.md
