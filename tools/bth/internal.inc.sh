#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
INTERNAL_OPS_TBL="$DIR/ops_internal.tbl"

awk -v INTERNAL_OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $INTERNAL_OPS_TBL)" \
	'BEGIN {print "; Generated from internal.inc.tmpl"} {gsub(/^_INTERNAL_OPS_$/, INTERNAL_OPS); print}' \
	$DIR/internal.inc.tmpl
