#!/usr/bin/env bash

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"

"$DIR/tools/bth/bin/bth" < $1

echo "1..1"
echo "ok 1"
