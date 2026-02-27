#!/bin/bash
set -e

# fetch all tags
git fetch --tags --quiet

source_branch=$2

# based on the branch we are on we want to limit the tags for determining the new tag
if [[ "$source_branch" == "master" ]]; then
  # on master we simply take all tags, get the newest and increment from there
  tags=$(git tag -l | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' || true)
  if [ -z "$tags" ]; then
    latest_tag="0.0.0"
  else
    latest_tag=$(echo "$tags" | sort -V | tail -n 1)
  fi

elif [[ "$source_branch" == pxc-* ]]; then
  # on lts branches we limit the filter by the lts version
  lts_major=$(echo "$source_branch" | cut -d'-' -f2)
  tags=$(git tag -l | grep -E "^$lts_major\.[0-9]+\.[0-9]+$" || true)
  if [ -z "$tags" ]; then
    latest_tag="$lts_major.0.0"
  else
    latest_tag=$(echo "$tags" | sort -V | tail -n 1)
  fi

else
  echo "Unknown supported branch type: $source_branch"
  # exit 1
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