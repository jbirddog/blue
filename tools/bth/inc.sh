#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
OPS_TBL="$DIR/ops_$WHICH.tbl"

awk -v OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $OPS_TBL)" \
	'BEGIN {print "; Generated from inc.tmpl"} {gsub(/^_OPS_$/, OPS); print}' \
	$DIR/inc.tmpl
