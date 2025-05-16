#!/bin/sh

awk -v OPCODE_TABLE="$(awk -v FS='\t' '{printf "| 0x%02X | %s | %s | %s |\n", NR - 1, $1, $3, $4}' ops.tbl)" \
	'{gsub(/^_OPCODE_TABLE_$/, OPCODE_TABLE); print}' \
	README.md.tmpl
