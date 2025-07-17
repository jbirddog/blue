# TODOs

## Maybe

1. Consider magenta + italics for runtime addr (like fin/; are yellow + italics if that holds)
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Likely go back to fasm for build time speed

## Words

1. Interpret word at compile time (cyan - done)
1. Call word at compile time (yellow - done)
1. Call word at run time (green - done)
1. Push compile time addr of word (magenta - done)
1. Push run time addr of word (white - done)

## Next

1. Reorder bytecodes after migration from dict
1. `;` needs to perform TCO
1. WORD_CCALL is broken

## Future

1. Release as blue
   1. Tag main as v5
   1. Make v6
   1. Change binary, asm file names
   1. Move to root, remove all old code (include bak)
   1. .1xo -> .bo, .1x -> .b
   1. Update CI job
1. Start getting the README.md together
1. Factor Makefile a bit for multiple ouput binaries
1. Make onex.1x, onex written in onex and bootstrapped from fasm version

## rt

How many files to include as `rt`?

### x8664.1xo

1. See things in `hello.macros.1xo`

### linux.1xo

1. See things in `hello.macros.1xo`

### kernel.1xo

1. `$ $$ !`
1. Move logic to read _src from stdin
   1. Words + exec `read`

### kernel.fin.1xo

1. `out bye`
