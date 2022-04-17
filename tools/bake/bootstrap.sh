#!/usr/bin/sh

rm -rf .build
mkdir -p .bootstrap/bin
mkdir -p .bootstrap/obj

blue bake.blue
nasm -f elf64 -o .bootstrap/obj/bake.o bake.asm
ld -o .bootstrap/bin/bake .bootstrap/obj/bake.o

.bootstrap/bin/bake build bake.blue 
echo $?
