# CONTRIBUTING

## For developer

1. To understand the [architecture](docs/architecture.md)
2. About [reporter](docs/reporter.md)
3. About various [shells](docs/shells.md)
4. How to [test](docs/test.md)

### About specfile translation process

The specfile is a valid shell script, but a translation process is performed to implement the scope,
line number etc. Each example group block and example block is translated to commands in a subshell.
Therefore changes inside those blocks do not affect the outside of the block. In other words it realizes
local variables and local functions in the specfile. This is very useful for describing a structured spec.
If you are interested in how to translate, use the `--translate` option.
