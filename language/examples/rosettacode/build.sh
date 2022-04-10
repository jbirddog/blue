#!/usr/bin/sh

mkdir -p .build/bin
mkdir -p .build/obj

rm -f output.txt
rm -rf docs

blue clear_the_screen.blue
nasm -f elf64 -o .build/obj/clear_the_screen.o clear_the_screen.asm
ld -o .build/bin/clear_the_screen .build/obj/clear_the_screen.o

blue commandline_args.blue
nasm -f elf64 -o .build/obj/commandline_args.o commandline_args.asm
ld -o .build/bin/commandline_args .build/obj/commandline_args.o

blue create_file.blue
nasm -f elf64 -o .build/obj/create_file.o create_file.asm
ld -o .build/bin/create_file .build/obj/create_file.o

blue fibonacci.blue
nasm -f elf64 -o .build/obj/fibonacci.o fibonacci.asm

blue hello_world.blue
nasm -f elf64 -o .build/obj/hello_world.o hello_world.asm
ld -o .build/bin/hello_world .build/obj/hello_world.o

blue program_name.blue
nasm -f elf64 -o .build/obj/program_name.o program_name.asm
ld -o .build/bin/program_name .build/obj/program_name.o

blue read_entire_file.blue
nasm -f elf64 -o .build/obj/read_entire_file.o read_entire_file.asm
ld -o .build/bin/read_entire_file .build/obj/read_entire_file.o
