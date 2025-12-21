#!/bin/bash
set -e

# split the tag and increment
major=$(echo "$1" | cut -d '.' -f 1)
minor=$(echo "$1" | cut -d '.' -f 2)
patch=$(echo "$1" | cut -d '.' -f 3)

minor=$((minor + 1))
patch=0

# return the pessimistic constraint
echo "$major.$minor.$patch"
