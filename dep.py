#!/usr/bin/env python3

"""Create dependency graph from `cflow` call graph."""

import re
import sys
from typing import List


def main(argv: List[str]) -> int:
    """Parse call graph, then create `tsort` and GraphViz output."""
    if len(argv) != 3:
        print(f"Usage: {argv[0]} infile outfile", file=sys.stderr)
        return 1

    infile = open(argv[1], "r")
    outfile = open(argv[2], "w")

    topgex = re.compile(r"^(\w+(\(\))?)(\s*<.+>(\s\(R\))?)?:?$")
    nestgex = re.compile(r"^    (\w+(\(\))?)(\s*<.+>(\s\(R\))?)?:?$")

    current_top = None

    print("digraph G {");

    for line in infile:
        top_m = re.match(topgex, line)
        if top_m is not None:
            current_top = top_m.group(1)
        else:
            bot_m = re.match(nestgex, line)
            if bot_m is not None:
                outfile.write(f"{current_top} {bot_m.group(1)}\n")
                print(f'    "{current_top}" -> "{bot_m.group(1)}";')


    print("}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
