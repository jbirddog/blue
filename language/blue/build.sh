#!/usr/bin/sh

mkdir -p bin
mkdir -p obj

nasm -f elf64 -o obj/sys.o sys.asm

nasm -f elf64 -o obj/str_test.o str_test.asm
ld -o bin/str_test obj/str_test.o

nasm -f elf64 -o obj/exit33.o examples/exit33.asm
ld -o bin/exit33 obj/exit33.o

nasm -f elf64 -o obj/fib.o examples/fib.asm

nasm -f elf64 -o obj/fib_test.o examples/fib_test.asm
ld -o bin/fib_test obj/fib_test.o

nasm -f elf64 -o obj/scratch.o examples/scratch.asm
ld -o bin/scratch obj/scratch.o obj/sys.o

nasm -f elf64 -o obj/echo.o examples/echo.asm
ld -o bin/echo obj/echo.o

nasm -f elf64 -o obj/blue.o blue.asm
ld -o bin/blue obj/blue.o

#
# rosetta code examples
#

nasm -f elf64 -o obj/rosettacode-program_name.o rosettacode/program_name/main.asm
ld -o bin/rosettacode-program_name obj/rosettacode-program_name.o

nasm -f elf64 -o obj/rosettacode-fibonacci_sequence.o rosettacode/fibonacci_sequence/lib.asm
