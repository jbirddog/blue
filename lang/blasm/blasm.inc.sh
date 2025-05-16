#!/bin/bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"
OPS_TBL="$DIR/../../ops.tbl"

awk -v OPS="$(awk -v FS='\t' '{printf "\t%s, %d, \\\\\\n", $1, $2}' $OPS_TBL)" '{gsub(/^_OPS_$/, OPS); print}' $DIR/blasm.inc.tmpl
