#!/usr/bin/sh

go test
go install .

cd blue
gfe sys.blue
gfe examples/exit33.blue
gfe examples/fib.blue
gfe examples/scratch.blue
./build.sh
cd ..
