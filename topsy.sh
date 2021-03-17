#!/usr/bin/env bash

# Assert arguments
if [ $# -gt 1 ]; then
    1>&2 echo "Usage: $0 c_source"
    exit 1
fi

# Dynamically take input from STDIN or args
input=${1--}

# Temporary files
call_graph=$(mktemp)
dep_graph=$(mktemp)

# Ensure proper cleanup
trap 'rm -f "$call_graph" "$dep_graph"; exit' 0 2 3 15

# Create the reverse call graph using cflow first.
# Add -ix flag if you want literally everything...
cflow -r <(cat "$input") > "$call_graph" 2> /dev/null

# Create dependency graph next
./dep.py "$call_graph" "$dep_graph"

# Topological sort
tsort < "$dep_graph"
