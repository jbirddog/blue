#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

mkdir -p bin
mkdir -p obj

echo "* Building BlueVM v5 x86_64/linux"

fasm v5.asm bin/tmp
cat bin/tmp bin/tmp > bin/v5
chmod +x bin/v5
./bin/v5

