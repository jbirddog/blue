#!/usr/bin/sh

BAKE=../../tools/bake/.build/bin/bake

command -v "${BAKE}" > /dev/null 2>&1 || {
	cd ../../tools/bake
	./bootstrap.sh
	cd -
}

$BAKE build echo.blue
$BAKE build fib_test.blue

cd rosettacode
./build.sh
cd ..
