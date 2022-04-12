#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

#
# move these to examples/build.sh when import search paths
#

blue examples/fib_test.blue
nasm -f elf64 -o .build/obj/fib_test.o examples/fib_test.asm
ld -o .build/bin/fib_test .build/obj/fib_test.o

blue examples/echo.blue
nasm -f elf64 -o .build/obj/echo.o examples/echo.asm
ld -o .build/bin/echo .build/obj/echo.o

cd tutorial
./build.sh
cd ../

cd examples/rosettacode
./build.sh
cd ../../
