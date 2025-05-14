#!/bin/bash

set -e

error_handler() {
  echo "Error on line $1, exit status: $2"
}

trap 'error_handler $LINENO $?' ERR

echo "* Building BlueVM x86_64/linux"

make

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
