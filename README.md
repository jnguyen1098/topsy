![](https://s4.gifyu.com/images/W7AjGejjKX.gif)

# topsy

A simple script that generates a bottom-up study sequence (given a C/C++ source file) that aids in understanding unfamiliar programs. An algorithm known as [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting) is used to create this sequence: topsy is merely an implementation that pipelines it (thanks to `cflow` and `tsort`).

## Usage

topsy can take input directly from `STDIN` or as the first arg (filename). It isn't possible to pass in flags when pipelining in from `STDIN`.

When `tsort` encounters a cycle in the graph (topological sort typically relies on DAGs), it will try its best to break the deadlock, but it isn't a "true" topological sort at that point. This is prevalent in recursive/cyclical function chains.

```
Usage: ./topsy [-a] [-v]
Generate topological sort for C/C++ source file

Options
-a,    output all symbols (external, static, typedef)
-v,    verbose output (print intermediate representations)
```

Note: `-v` does not imply `-a`. Arguments must come after the filename.

## Features

- Verbose output support, allowing for printing of the intermediate structures:
  - `cflow` call graph
  - `dep.py` dependency graph
- Support for outputting all symbols (including `typedef`s, `extern`s, and `static`s)

## Examples

```bash
# Running topsy with example_1.c
$ ./topsy example_1.c
parse_preprocedure_1()
parse_preprocedure_2()
parse_preprocedure_3()
parse_something()
main()
```

```bash
# The above command, but with verbose output
$ ./topsy example_1.c -v
Call graph:
main() <int main (void) at /dev/fd/63:15>
parse_preprocedure_1():
    parse_something() <void parse_something (void) at /dev/fd/63:8>:
        main() <int main (void) at /dev/fd/63:15>
parse_preprocedure_2():
    parse_something() <void parse_something (void) at /dev/fd/63:8>:
        main() <int main (void) at /dev/fd/63:15>
parse_preprocedure_3():
    parse_something() <void parse_something (void) at /dev/fd/63:8>:
        main() <int main (void) at /dev/fd/63:15>
parse_something() <void parse_something (void) at /dev/fd/63:8>:
    main() <int main (void) at /dev/fd/63:15>

Dependency graph:
parse_preprocedure_1() parse_something()
parse_preprocedure_2() parse_something()
parse_preprocedure_3() parse_something()
parse_something() main()

Topological sort:
parse_preprocedure_1()
parse_preprocedure_2()
parse_preprocedure_3()
parse_something()
main()
```

## TODO

- Multiple file support

- Direct translation between `cflow`'s `--include` flag (i.e. `s`, `t`, and `x`)