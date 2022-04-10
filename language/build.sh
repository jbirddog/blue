#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue sys.blue
nasm -f elf64 -o .build/obj/sys.o sys.asm

#
# move these to examples/build.sh when import search paths
#

blue examples/exit33.blue
nasm -f elf64 -o .build/obj/exit33.o examples/exit33.asm
ld -o .build/bin/exit33 .build/obj/exit33.o

blue examples/fib.blue
nasm -f elf64 -o .build/obj/fib.o examples/fib.asm

blue examples/fib_test.blue
nasm -f elf64 -o .build/obj/fib_test.o examples/fib_test.asm
ld -o .build/bin/fib_test .build/obj/fib_test.o

blue examples/scratch.blue
nasm -f elf64 -o .build/obj/scratch.o examples/scratch.asm
ld -o .build/bin/scratch .build/obj/scratch.o .build/obj/sys.o

blue examples/echo.blue
nasm -f elf64 -o .build/obj/echo.o examples/echo.asm
ld -o .build/bin/echo .build/obj/echo.o

#
# rosetta code examples
#

cd examples/rosettacode
./build.sh
cd ../../
