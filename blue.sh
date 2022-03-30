#!/usr/bin/sh

go test
go install .

cd language/blue
blue blue.blue
blue str_test.blue
blue sys.blue
blue examples/exit33.blue
blue examples/fib.blue
blue examples/fib_test.blue
blue examples/scratch.blue
blue examples/echo.blue
blue rosettacode/program_name/main.blue
blue rosettacode/fibonacci_sequence/lib.blue
./build.sh
cd ../../
