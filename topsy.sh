#!/usr/bin/env bash

# Assert arguments
if [ $# -gt 2 ]; then
    1>&2 echo "Usage: $0 c_source [-a]"
    exit 1
fi

# Shift argument before parsing flags
OPTIND=2

# Parse verbosity flags
while getopts ":a" opt; do
    case $opt in
        a)
            # Track all symbols
            flag='-ix'
            ;;
        \?)
            # Just in case I add more args in the future
            echo "Invalid option: -$OPTARG. Ignoring." >&2
            ;;
    esac
done

# Dynamically take input from STDIN or args
input=${1--}

# Temporary files
call_graph=$(mktemp)
dep_graph=$(mktemp)

# Ensure proper cleanup
trap 'rm -f "$call_graph" "$dep_graph"; exit' 0 2 3 15

# Create the reverse call graph using cflow first.
cflow -r $flag <(cat "$input") > "$call_graph" 2> /dev/null

# Create dependency graph next
./dep.py "$call_graph" "$dep_graph"

# Topological sort
tsort < "$dep_graph"
