#!/usr/bin/env bash

set -e

DIR="$( dirname -- "$( readlink -f -- "$0"; )"; )"

"$DIR/tools/bth/bin/bth" < $1
