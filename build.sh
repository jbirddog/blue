#!/usr/bin/sh

go test
go install .

cd language
./build.sh
cd ../
