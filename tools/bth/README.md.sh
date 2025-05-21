#!/bin/sh

awk -v OPCODE_TABLE="$(awk -v FS='\t' '{printf "| 0x%02X | %s | %s | %s |\n", NR - 1 + 0x80, $1, $3, $4}' ops_low.tbl)" \
	'BEGIN {print "_This file is generated from README.md.tmpl_\n"} {gsub(/^_OPCODE_TABLE_$/, OPCODE_TABLE); print}' \
	README.md.tmpl
