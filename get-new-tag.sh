#!/bin/bash
set -e

# get the latest tag => default to 0.0.0
git fetch --tags --quiet
tags=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' || true)
if [ -z "$tags" ]; then
  latest_tag="0.0.0"
else
  latest_tag=$(echo "$tags" | sort -V | tail -n 1)
fi

# split the tag and increment
major=$(echo "$latest_tag" | cut -d '.' -f 1)
minor=$(echo "$latest_tag" | cut -d '.' -f 2)
patch=$(echo "$latest_tag" | cut -d '.' -f 3)

if [[ "$1" == "major" ]]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [[ "$1" == "minor" ]]; then
  minor=$((minor + 1))
  patch=0
elif [[ "$1" == "patch" ]]; then
  patch=$((patch + 1))
else
  echo "Unknown increment type: $1"
  exit 1
fi

new_tag="$major.$minor.$patch"

echo $new_tag