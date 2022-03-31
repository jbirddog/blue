#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue main.blue
nasm -f elf64 -o .build/obj/hello_world.o main.asm
ld -o .build/bin/hello_world .build/obj/hello_world.o
