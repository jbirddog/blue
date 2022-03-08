#!/usr/bin/sh

go test
go run .

cd blue
./build.sh
cd ..
