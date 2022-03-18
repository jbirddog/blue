#!/usr/bin/sh

go test
go install .

cd blue
gfe sys.blue
gfe examples/exit33.blue
gfe examples/fib.blue
gfe examples/fib_test.blue
gfe examples/scratch.blue
gfe examples/echo.blue
./build.sh
cd ..
