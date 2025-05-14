#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

mkdir -p bin
mkdir -p obj

echo "* Building BlueVM x86_64/linux"

fasm2/fasm2 bluevm.asm bin/bluevm

echo ""
echo "* Building bs0 files"

./lang/blasm/blasm tests/init.bla obj/test_init.bs0
./lang/blasm/blasm tests/exit.bla obj/test_exit.bs0
./lang/blasm/blasm tests/ifelse.bla obj/test_ifelse.bs0
./lang/blasm/blasm tests/assert.bla obj/test_assert.bs0
./lang/blasm/blasm tests/bc.bla obj/test_bc.bs0
./lang/blasm/blasm tests/blue_proto.bla obj/test_blue_proto.bs0
./lang/blasm/blasm tests/ops.bla obj/test_ops.bs0

pushd lang/blang > /dev/null
python blang.py < examples/hello_world.bl > ../../obj/hello_world.bs0
popd > /dev/null

pushd lang/blue > /dev/null
python blue.py < examples/exit.blue > ../../obj/blue_exit.bs0
popd > /dev/null

./lang/blasm/blasm lang/blasm/examples/exit.bla obj/blasm_exit.bs0
./lang/blasm/blasm lang/blasm/examples/hello_world.bla obj/blasm_hello_world.bs0

echo ""
echo "* Running bs0 test cases"

./bin/bluevm < obj/test_exit.bs0
./bin/bluevm < obj/test_init.bs0
./bin/bluevm < obj/test_ifelse.bs0
./bin/bluevm < obj/test_bc.bs0
./bin/bluevm < obj/test_assert.bs0
./bin/bluevm < obj/test_ops.bs0
./bin/bluevm < obj/test_blue_proto.bs0

echo "** Blang Example - Hello World"
./bin/bluevm < obj/hello_world.bs0

echo "** Blasm Example - Hello World"
./bin/bluevm < obj/blasm_hello_world.bs0

echo "** Blue Example - Exit"
./bin/bluevm < obj/blue_exit.bs0

echo "** Blasm Example - Exit"
./bin/bluevm < obj/blasm_exit.bs0

echo ""
echo "* Done"
