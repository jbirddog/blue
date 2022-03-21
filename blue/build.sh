#!/usr/bin/sh

mkdir -p bin
mkdir -p obj

nasm -f elf64 -o obj/sys.o sys.asm

nasm -f elf64 -o obj/str_test.o examples/str_test.asm
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
