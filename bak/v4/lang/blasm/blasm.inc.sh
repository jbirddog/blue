#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
OPS_TBL="$DIR/../../ops_vm.tbl"

awk -v OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $OPS_TBL)" \
	'BEGIN {print "; Generated from blasm.inc.tmpl"} {gsub(/^_OPS_$/, OPS); print}' \
	$DIR/blasm.inc.tmpl
