#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

mkdir -p obj

echo "* Building BlueVM x86_64/linux"

make

echo ""
echo "* Building bs0 files"

./lang/blasm/blasm -n tests/init.bla obj/test_init.bs0
./lang/blasm/blasm -n tests/exit.bla obj/test_exit.bs0
./lang/blasm/blasm -n tests/ifelse.bla obj/test_ifelse.bs0
./lang/blasm/blasm -n tests/assert.bla obj/test_assert.bs0
./lang/blasm/blasm -n tests/bc.bla obj/test_bc.bs0
./lang/blasm/blasm -n tests/blue_proto.bla obj/test_blue_proto.bs0
./lang/blasm/blasm -n tests/ops.bla obj/test_ops.bs0

pushd lang/blue > /dev/null
python blue.py < examples/exit.blue > ../../obj/blue_exit.bs0
popd > /dev/null

./lang/blasm/blasm -n lang/blasm/examples/exit.bla obj/blasm_exit.bs0
./lang/blasm/blasm -n lang/blasm/examples/hello_world.bla obj/blasm_hello_world.bs0

echo ""
echo "* Running bs0 test cases"

./bin/bluevm < obj/test_exit.bs0
./bin/bluevm < obj/test_init.bs0
./bin/bluevm < obj/test_ifelse.bs0
./bin/bluevm < obj/test_bc.bs0
./bin/bluevm < obj/test_assert.bs0
./bin/bluevm < obj/test_ops.bs0
./bin/bluevm < obj/test_blue_proto.bs0

echo "** Blasm Example - Hello World"
./bin/bluevm < obj/blasm_hello_world.bs0

echo "** Blue Example - Exit"
./bin/bluevm < obj/blue_exit.bs0

echo "** Blasm Example - Exit"
./bin/bluevm < obj/blasm_exit.bs0

echo ""
echo "* Done"
