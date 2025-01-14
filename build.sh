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

./examples/blang/blang.pl < tests/halt.bl > obj/test_halt.bs0
./examples/blang/blang.pl < tests/ops.bl > obj/test_ops.bs0

echo "* Running bs0 test cases"

echo "** Test Halt"
./bin/bluevm < obj/test_halt.bs0

echo "** Test Ops"
./bin/bluevm < obj/test_ops.bs0

echo "* Done"
