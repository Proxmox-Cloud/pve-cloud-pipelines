#!/bin/bash
set -e

git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# commit and push (child can insert sed before this)
git add .
git commit -m "$1"
git push origin HEAD:master

echo $UPSTREAM_TAG_MESSAGE

# only trigger tag push on -all- release tags
if [[ "$UPSTREAM_TAG_MESSAGE" == *"-all-"* ]]; then
    git tag -f $UPSTREAM_TAG_MESSAGE
    git push -f origin $UPSTREAM_TAG_MESSAGE
fi