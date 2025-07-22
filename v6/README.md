# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. Unlike the traditional `colorForth` system, Blue is a single shot application with a sole focus on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe and solve the problem at hand.

Blue aims to:

1. Have a reasonably small, simplistic and hackable codebase that a single human can completely understand
1. Help create minimalistic handcrafted applications
1. Bring some fun back into the world

This is the reference implementation for x86_64 Linux.

## Opcodes

0. fin
1. define word
2. end word
3. call word at compile time
4. call word at run time
5. interpret word at compile time
6. Push the compile time address of word on the data stack
7. Push the run time address of word on the data stack
8. Move qword from `src` to `dst`
9. Push the next qword from `src` on the data stack
10. Duplicate the top of the data stack
11. Pop two data stack elements, add them and push the result
12. Pop two data stack elements, subtract them and push the result
13. Pop two data stack elements, or them and push the result
14. Pop two data stack elements, shift the second left the number of times in the first and push the result
15. Push the compile time address of `dst`
16. Push the run time address of `dst`
17. Pop two data stack elements, Set the address in the first to the value in the second and push the result
18. Pop address from the data stack and push the value of that address
19. Move a byte from the top of the stack to `dst` 
19. Move a word from the top of the stack to `dst` 
19. Move a dword from the top of the stack to `dst` 
19. Move a qword from the top of the stack to `dst`
20. Print a newline when visually rendering bytecode

## The Structural Dynamics of Flow
