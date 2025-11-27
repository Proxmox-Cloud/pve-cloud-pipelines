#!/bin/bash
set -e

# set config based on the current commit for auto commit
git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# get the latest tag => default to 0.0.0
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

increment=${CI_COMMIT_TAG#release-}

if [ "$increment" == "major" ]; then
  major=$((major + 1))
  minor=0
  patch=0
elif [ "$increment" == "minor" ]; then
  minor=$((minor + 1))
  patch=0
elif [ "$increment" == "patch" ]; then
  patch=$((patch + 1))
else
  echo "Unknown increment type: $increment"
  exit 1
fi

new_tag="$major.$minor.$patch"

echo $new_tag

# tag and push => created by job ci token, will not trigger the tag released pipeline
git tag "$new_tag" -m "$CI_COMMIT_TAG"
git push origin "$new_tag"

# manually trigger the pipeline that should have been invoked by pushing the tag
# gitlab ci is ass
curl --request POST \
  --form "token=${CI_JOB_TOKEN}" \
  --form "ref=${new_tag}" \
  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/trigger/pipeline"