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

./examples/blang/blang.pl < tests/exit.bl > obj/test_exit.bs0
./examples/blang/blang.pl < tests/bc.bl > obj/test_bc.bs0
./examples/blang/blang.pl < tests/custom_op.bl > obj/test_custom_op.bs0
./examples/blang/blang.pl < tests/ops.bl > obj/test_ops.bs0

echo "* Running bs0 test cases"

echo "** Test Exit"
./bin/bluevm < obj/test_exit.bs0

echo "** Test Compiling and Calling Bytecode"
./bin/bluevm < obj/test_bc.bs0

echo "** Test Custom Opcode"
./bin/bluevm < obj/test_custom_op.bs0

echo "** Test Ops"
./bin/bluevm < obj/test_ops.bs0

echo "* Done"
