#!/bin/bash
set -e

# either called in pipeline directly via tag push or in downstream
TRIGGER_TAG=${CI_COMMIT_TAG:-$UPSTREAM_TAG_MESSAGE}

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

if [[ "$TRIGGER_TAG" == *"-major" ]]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [[ "$TRIGGER_TAG" == *"-minor" ]]; then
  minor=$((minor + 1))
  patch=0
elif [[ "$TRIGGER_TAG" == *"-patch" ]]; then
  patch=$((patch + 1))
else
  echo "Unknown increment type: $TRIGGER_TAG"
  exit 1
fi

new_tag="$major.$minor.$patch"

echo $new_tag