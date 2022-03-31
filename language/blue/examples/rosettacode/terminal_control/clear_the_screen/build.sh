#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

blue main.blue
nasm -f elf64 -o .build/obj/clear_the_screen.o main.asm
ld -o .build/bin/clear_the_screen .build/obj/clear_the_screen.o
