# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. It is a single shot application with an intentionally limited scope that focuses on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe the problem at hand.

This is the reference implementation for x86_64 Linux.

## Comparison with colorForth

It is important to note that I have not used or seen the source for an actual `colorForth` system. I do believe I have digested all the (limited) material that is available online. When I say `colorForth` I am likely also describing `arrayForth` or `etherforth` as honestly I lose track of where they overlap/differ. With that being said, this comparison is in good faith but may not end up being 100% correct:

### Similarities

1. Concatenative/stack-based
9. No stack effect declarations
2. Use of binary bytecode files instead of the more traditional text file as the input
3. Data stack is implemented as a circular buffer
4. Dictionary is implemented as an array
5. The use of each word describes its execution semantics (compile/interpret)
   1. Defining a word does not enter compile mode, `;` does not leave compile mode, there is no `]`, `[`, `immediate`, `postpone`, etc
6. Word definitions do not have to have a `;` - they can fallthrough to the next word
7. Defined words are available immediately
8. `;` will perform tail-call optimization when preceeded by a call
9. Any previously defined word can be called while interpreting

### Differences

1. Blue is a single shot application (used like `gcc`) instead of a living application (like an `os`/`emacs`)
2. Does not have a custom keyboard mapping
3. The bytecode format is not the same
4. There are no comments or shadow blocks
5. Block files are not used
6. Has more opcodes and less pre-defined words

## The Structural Dynamics of Flow
