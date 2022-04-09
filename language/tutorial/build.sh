#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue tutorial1.blue
nasm -f elf64 -o .build/obj/tutorial1.o tutorial1.asm
ld -o .build/bin/tutorial1 .build/obj/tutorial1.o
