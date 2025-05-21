#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
LOW_OPS_TBL="$DIR/ops/low.tbl"

awk -v LOW_OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $LOW_OPS_TBL)" \
	'BEGIN {print "; Generated from ops.inc.tmpl"} {gsub(/^_LOW_OPS_$/, LOW_OPS); print}' \
	$DIR/ops.inc.tmpl
