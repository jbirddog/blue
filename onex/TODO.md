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
1. Factor more in `hello.1xo`

## Future

1. ed is always showing `fin`
1. `;` needs to perform TCO
1. Start getting the README.md together
1. Tracking src in dict is more of a reason to move more things to `1xo` files
   1. Functionality and binary size-wise
   1. Basically anything but bytecode handlers/ds_push/ds_pop in bytecode
   1. Also look at making some things bytecode (like or, shl)
      1. This has the advantage of knowing you can't `interp` it, etc
      1. -, +, `b,`, dup...
      1. ^ this
      1. binary and 1x* files are smaller
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
