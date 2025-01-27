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

pushd lang/blang
python blang.py < ../../tests/exit.bl > ../../obj/test_exit.bs0
python blang.py < ../../tests/init.bl > ../../obj/test_init.bs0
python blang.py < ../../tests/ifelse.bl > ../../obj/test_ifelse.bs0
python blang.py < ../../tests/bc.bl > ../../obj/test_bc.bs0
python blang.py < ../../tests/assert.bl > ../../obj/test_assert.bs0
python blang.py < ../../tests/ops.bl > ../../obj/test_ops.bs0
python blang.py < ../../tests/blue_proto.bl > ../../obj/test_blue_proto.bs0
python blang.py < examples/hello_world.bl > ../../obj/hello_world.bs0
popd

pushd lang/blue
python blue.py < examples/exit.blue > ../../obj/blue_exit.bs0
popd

echo "* Running bs0 test cases"

echo "** Test Exit"
./bin/bluevm < obj/test_exit.bs0

echo "** Test Init"
./bin/bluevm < obj/test_init.bs0

echo "** Test If Else"
./bin/bluevm < obj/test_ifelse.bs0

echo "** Test Compiling and Calling Bytecode"
./bin/bluevm < obj/test_bc.bs0

echo "** Test Custom Opcode - Assert"
./bin/bluevm < obj/test_assert.bs0

echo "** Test Ops"
./bin/bluevm < obj/test_ops.bs0

echo "** Test Blue Prototype"
./bin/bluevm < obj/test_blue_proto.bs0

echo "** Example - Hello World"
./bin/bluevm < obj/hello_world.bs0

#xxd obj/blue_exit_pl.bs0
#echo "----"
#xxd obj/blue_exit.bs0

echo "** Blue Example - Exit"
./bin/bluevm < obj/blue_exit.bs0

echo "* Done"
