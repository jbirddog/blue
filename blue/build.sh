#!/usr/bin/sh

mkdir -p bin
mkdir -p obj

nasm -f elf64 -o obj/sys.o sys.asm

nasm -f elf64 -o obj/exit33.o examples/exit33.asm
ld -o bin/exit33 obj/exit33.o obj/sys.o

nasm -f elf64 -o obj/fib.o examples/fib.asm
ld -o bin/fib obj/fib.o obj/sys.o

nasm -f elf64 -o obj/scratch.o examples/scratch.asm
ld -o bin/scratch obj/scratch.o obj/sys.o
