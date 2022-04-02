#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

nasm -f elf64 -o .build/obj/sys.o sys.asm

nasm -f elf64 -o .build/obj/str_test.o str_test.asm
ld -o .build/bin/str_test .build/obj/str_test.o

nasm -f elf64 -o .build/obj/exit33.o examples/exit33.asm
ld -o .build/bin/exit33 .build/obj/exit33.o

nasm -f elf64 -o .build/obj/fib.o examples/fib.asm

nasm -f elf64 -o .build/obj/fib_test.o examples/fib_test.asm
ld -o .build/bin/fib_test .build/obj/fib_test.o

nasm -f elf64 -o .build/obj/scratch.o examples/scratch.asm
ld -o .build/bin/scratch .build/obj/scratch.o .build/obj/sys.o

nasm -f elf64 -o .build/obj/echo.o examples/echo.asm
ld -o .build/bin/echo .build/obj/echo.o

nasm -f elf64 -o .build/obj/blue.o blue.asm
ld -o .build/bin/blue .build/obj/blue.o

#
# rosetta code examples
#

nasm -f elf64 -o .build/obj/rosettacode-program_name.o examples/rosettacode/program_name/main.asm
ld -o .build/bin/rosettacode-program_name .build/obj/rosettacode-program_name.o

nasm -f elf64 -o .build/obj/rosettacode-fibonacci_sequence.o examples/rosettacode/fibonacci_sequence/lib.asm

cd examples/rosettacode/command-line_arguments
./build.sh
cd ../../../

cd examples/rosettacode/terminal_control/clear_the_screen
./build.sh
cd ../../../../

cd examples/rosettacode/hello_world/text
./build.sh
cd ../../../../
