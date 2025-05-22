#!/usr/bin/env bash

set -e

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"

"$DIR/tools/bth/bin/bth" < $1

#echo "TAP version 14"
#echo "ok"
#echo "1..1"
#echo ""
