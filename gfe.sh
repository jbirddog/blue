#!/usr/bin/sh

go test
go install .

cd blue
gfe blue.blue
gfe str_test.blue
gfe sys.blue
gfe examples/exit33.blue
gfe examples/fib.blue
gfe examples/fib_test.blue
gfe examples/scratch.blue
gfe examples/echo.blue
gfe rosettacode/program_name/main.blue
gfe rosettacode/fibonacci_sequence/lib.blue
./build.sh
cd ..
