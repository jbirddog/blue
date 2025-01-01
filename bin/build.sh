#!/usr/bin/sh

fasm blue.asm bin/blue

cat x86_64/elf/pre.bs1 \
  demo.bs1 \
  | grep -v "#" \
  | xxd -p -r \
  | ./bin/blue > demo && chmod +x demo
