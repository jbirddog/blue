#!/bin/bash

set -e

mkdir -p bin
mkdir -p obj

echo "* Building s120 x86_64/linux"

fasm s120.asm bin/s120

echo "* Confirming s120 output"

grep -v "#" test_data/000.bs1 | xxd -p -r > obj/000_xxd.bs0
./bin/s120 < test_data/000.bs1 > obj/000_s120.bs0

cmp obj/000_xxd.bs0 obj/000_s120.bs0

echo "* Building Blue x86_64/linux"

fasm blue.asm bin/blue

echo "* Building example exit7"

cat \
  x86_64/elf/pre.bs1 \
  examples/x86_64/linux/exit7.bs1 \
  x86_64/elf/post.bs1 \
  | grep -v "#" \
  | xxd -p -r \
  | ./bin/blue > bin/exit7 && chmod +x bin/exit7

echo "* Building example hello_world"

cat \
  x86_64/elf/pre.bs1 \
  examples/x86_64/linux/hello_world.bs1 \
  x86_64/elf/post.bs1 \
  | grep -v "#" \
  | xxd -p -r \
  | ./bin/blue > bin/hello_world && chmod +x bin/hello_world
