#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue main.blue
nasm -f elf64 -o .build/obj/argv.o main.asm
ld -o .build/bin/argv .build/obj/argv.o
