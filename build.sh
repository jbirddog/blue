#!/usr/bin/sh

go test
go install .

cd tools/bake
./bootstrap.sh
cd ../../

cd language
./build.sh
cd ../
