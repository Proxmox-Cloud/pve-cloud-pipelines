#!/bin/bash
set -e

build_increment=$1
build_type=$2

new_tag=$(/scripts/get-new-tag.sh $build_increment)

echo "new tag based on build_increment: $new_tag" >&2
 
if [[ "$build_type" == "rc" ]]; then
  # create / switch to rc branch
  git checkout "$new_tag-rc" >&2 || git checkout -b "$new_tag-rc" >&2

  # merge in latest master state and push it
  git merge master >&2 && git push origin $new_tag-rc >&2

  # get latest rc release tag on the branch
  new_rc_tag=$(/scripts/get-new-rc-tag.sh $new_tag)

  # create the tag and push it
  git tag "$new_rc_tag" >&2
  git push origin "$new_rc_tag" >&2

  # return the rc tag for building etc
  echo $new_rc_tag

elif [[ "$build_type" == "release" ]]; then
  # on release we want to cleanup rc branches
  if git ls-remote --heads origin | grep -q "refs/heads/${new_tag}-rc"; then
    echo "deleting rc release branch ${new_tag}-rc" >&2
    git push origin --delete "${new_tag}-rc" >&2
  else
    echo "no rc branch found! prod release without rc first?" >&2
  fi

  # create the tag and push it
  git tag "$new_tag" >&2
  git push origin "$new_tag" >&2

  # simply echo the normal new_tag as return value
  echo $new_tag

else
  echo "Unknown build type: $build_type"
  exit 1
fi