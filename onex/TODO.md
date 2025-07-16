# TODOs

## Maybe

1. Consider magenta + italics for runtime addr (like fin/; are yellow + italics if that holds)
1. Add `bye`, remove BC_FIN
1. Top of stack always in rax?
1. Dict entry 0x00 can have not found handler
1. Likely go back to fasm for build time speed

## Keep in Mind

1. There is no ip - just compiling byte code top to bottom
1. Control flow happens via compiled machine code
1. Return stack is rsp
1. Data stack wraps

## Words

1. Interpret word at compile time (cyan - done)
1. Call word at compile time (yellow - done)
1. Call word at run time (green)
1. Push compile time addr of word (magenta - done)
1. Push run time addr of word (white - done)

## Next

1. Top level handling of `;`
1. Call word at run time
1. Move all but `org`, `$$` out of `dict` and into bytecode

## Future

1. Reorder bytecodes after migration from dict
1. Check magic before `next`ing bytecode
1. ed is always showing `fin`
   1. Length check needs to happen, ord(substr is returning 0
1. ed has some display cap
1. `;` needs to perform TCO
1. Start getting the README.md together
1. Factor Makefile a bit for multiple ouput binaries
1. Make onex.1x so onex can be written in onex and bootstrapped from fasm version

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
