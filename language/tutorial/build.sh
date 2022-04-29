#!/usr/bin/sh

cd ../../tools/bake
./bootstrap.sh
cd -

../../tools/bake/.build/bin/bake build tutorial1.blue
../../tools/bake/.build/bin/bake build tutorial2.blue
../../tools/bake/.build/bin/bake build tutorial3.blue
