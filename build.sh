#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

mkdir -p bin
mkdir -p obj

echo "* Building BlueVM x86_64/linux"

fasm bluevm.asm bin/bluevm

echo "* Building bs0 files"

./examples/blang/blang.pl < examples/blang/test_ops.bl > obj/test_ops.bs0

echo "* Running bs0 test cases"

./bin/bluevm < obj/test_ops.bs0

echo "* Done"
