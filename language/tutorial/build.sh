#!/usr/bin/sh

BAKE=../../tools/bake/.build/bin/bake

command -v "${BAKE}" > /dev/null 2>&1 || {
	cd ../../tools/bake
	./bootstrap.sh
	cd -
}

$BAKE build tutorial1.blue
$BAKE build tutorial2.blue
$BAKE build tutorial3.blue
