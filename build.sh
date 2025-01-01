#!/bin/bash

set -e

mkdir -p bin

fasm blue.asm bin/blue

echo "Building example exit7"

cat \
  x86_64/elf/pre.bs1 \
  examples/x86_64/linux/exit7.bs1 \
  x86_64/elf/post.bs1 \
  | grep -v "#" \
  | xxd -p -r \
  | ./bin/blue > bin/exit7 && chmod +x bin/exit7