![](https://s4.gifyu.com/images/W7AjGejjKX.gif)

# topsy

This is a pipeline script that generates a bottom-up plan of study for a given C/C++ source file. Using tools your Linux system already has (GNU `cflow` and `tsort`), topsy lists a total ordering of a source file's functions/symbols, aiding those studying unfamiliar code. [Dependency graphs](https://en.wikipedia.org/wiki/Dependency_graph) and [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting) are used to derive these sequences.

## Motivation

Take for example a program whose `main()` calls `parse_something()`, which itself calls `parse_preprocedure_1()`, `parse_preprocedure_2()` and `parse_preprocedure_3()`. We can visualize the procedural dependencies using a dependency graph, which in this case would be:

<p align="center">
    <img alt="dependency graph" src="https://i.imgur.com/QxVyott.png">
</p>

In order to understand the program in its entirety, someone who learns "top-down" may study `main()` first, then `parse_something()`, and then the three `parse_preprocedure...` functions. This is pretty straightforward as you can just read the functions _ad hoc_ and jump in and out of the functions/`ctags` as you go along, but how about for those who prefer learning bottom-up? Still possible, but a little more work is needed.

We need to use topological sorting in order to interpret the dependency graph (above) as a partial ordering and then create a total ordering that _attempts_ to obey the partial ordering rules above. In laymen terms, a bottom-up study plan would tell you that in order to understand `main()`, you need to understand `parse_something()`, and in order to understand that, you'd need to understand the three `parse_preprocedure...` functions. So, by this logic, we would start off at the `parse_preprocedure...` functions and work out way inside-out. A sequence to understand `example_1.c` (ergo, the resulting topological sort) could be:

- `parse_preprocedure_1()`

- `parse_preprocedure_2()`

- `parse_preprocedure_3()`

- `parse_something()`

- `main()`

A basic way to visualize the topological sorting technique used in GNU `tsort` (specifically [Kahn's algorithm](https://en.wikipedia.org/wiki/Topological_sorting#Kahn's_algorithm)) is to continually pop off (or in this case, "learn") nodes that have no dependencies (i.e. no arrows pointing in to them) until the graph is empty. In the case of there being a cycle (as is the case with recursive functions and cyclical function chains), arbitrarily break a tie.

It's pretty easy to intuitively derive where to learn when it comes to this simple example, but imagine a [1000+ line source file with many functions](https://i.imgur.com/vwkSMl4.png). As you can see, the topological sort isn't that obvious anymore. That's where topsy comes in. It aims to automate this process as much as possible using tools your Linux system already has.

## Usage

topsy can take input directly from `STDIN` or as the first arg (filename). It isn't possible to pass in flags when pipelining in from `STDIN`.

When `tsort` encounters a cycle in the graph (topological sort typically relies on DAGs), it will try its best to break the deadlock, but it isn't a "true" topological sort at that point. This is prevalent in recursive/cyclical function chains.

```
Usage: ./topsy [-a] [-v]
Generate topological sort for C/C++ source file

Options
-a,    output all symbols (external, static, typedef)
-v,    verbose output (print intermediate representations)
       and generate GraphViz dependency graph dot/gv file
```

Note: `-v` does not imply `-a`. Arguments must come after the filename.

## Features

- Verbose output support, allowing for printing of the intermediate structures:
  - `cflow` call graph
  - `dep.py` dependency graph
  - GraphViz gv/dot file export for the aforementioned `dep.py` dependency graph
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
