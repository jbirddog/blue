#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
TAP_OPS_TBL="$DIR/ops_tap.tbl"

awk -v TAP_OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $TAP_OPS_TBL)" \
	'BEGIN {print "; Generated from tap.inc.tmpl"} {gsub(/^_TAP_OPS_$/, TAP_OPS); print}' \
	$DIR/tap.inc.tmpl
