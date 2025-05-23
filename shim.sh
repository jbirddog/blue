#!/usr/bin/env bash

set -e

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"

echo "$DIR/tools/bth/bin/bth"
"$DIR/tools/bth/bin/bth" < $1
