# Blue

Blue is a single-pass bytecode interpreter for a [colorForth](https://colorforth.github.io/index.html) dialect. It is a single shot application with an intentionally limited scope that focuses on generating output. Like any Forth, an emphasis is placed on building user defined vocabularies to describe the problem at hand.

## Comparison with colorForth

It is important to note that I have not used or seen the source for an actual `colorForth` system. I do believe I have digested all the (limited) material that is available online. With that being said, this comparison is in good faith but may not end up being 100% correct:

### Similarities

1. Concatenative/stack-based
2. Use of binary bytecode files instead of the more traditional text file as the input
3. The use of each word describes its execution semantics (compile/interpret)
   1. Defing a word does not enter compile mode, `;` does not leave compile mode, there are no `[`/`]`
4. Word definitions do not have to have a `;` - they can fallthrough to the next word
5. Defined words are available immediately
6. `;` will perform tail-call optimization when preceeded by a call

### Differences

## The Structural Dynamics of Flow
