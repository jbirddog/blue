#!/usr/bin/sh

fasm blue.asm bin/blue

cat
  x86_64/elf/pre.bs1 \
  demo.bs1 \
  x86_64/elf/post.bs1 \
  | grep -v "#" \
  | xxd -p -r \
  | ./bin/blue > bin/demo && chmod +x bin/demo
