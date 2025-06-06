#!/bin/sh

awk \
	-v INTERNAL_OPS_TBL="$(awk -v FS='\t' '{printf "| 0x%02X | %s | %s | %s |\n", NR - 1 + 0x80, $1, $3, $4}' ops_internal.tbl)" \
	-v TAP_OPS_TBL="$(awk -v FS='\t' '{printf "| 0x%02X | %s | %s | %s |\n", NR - 1 + 0xC0, $1, $3, $4}' ops_tap.tbl)" \
	'BEGIN {print "_This file is generated from README.md.tmpl_\n"}
	{
		gsub(/^_INTERNAL_OPS_TBL_$/, INTERNAL_OPS_TBL);
		gsub(/^_TAP_OPS_TBL_$/, TAP_OPS_TBL);
		print
	}
	' \
	README.md.tmpl
