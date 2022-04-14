#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue bake.blue
nasm -f elf64 -o .build/obj/bake.o bake.asm
ld -o .build/bin/bake .build/obj/bake.o
