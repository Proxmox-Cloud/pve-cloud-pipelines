#!/bin/bash
set -e

# set config based on the current commit for auto commit
git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# create / switch to the rc branch
git fetch origin # fetch existing branches
git checkout -B $1-rc origin/$1-rc 2>/dev/null || git checkout -b $1-rc # switch/create

git merge $CI_COMMIT_SHA # merge in recent changes in case its not up to date

git push origin $1-rc # push the full rc branch