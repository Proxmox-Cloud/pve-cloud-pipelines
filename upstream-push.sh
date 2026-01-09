#!/bin/bash
set -e

git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# this is needed for pipeline paralellism for other artifacts
git fetch origin
git merge origin/${2:-"master"} || {
    echo "Merge conflicts detected, aborting."
    exit 1
}

# commit and push (child can insert sed before this)
git add .
git commit -m "$1"
git push origin HEAD:${2:-"master"}

echo $UPSTREAM_TAG_MESSAGE
git tag -f $UPSTREAM_TAG_MESSAGE
git push -f origin $UPSTREAM_TAG_MESSAGE

# trigger pipeline after wait
sleep 10

curl --request POST \
  --form "token=${CI_JOB_TOKEN}" \
  --form "ref=$UPSTREAM_TAG_MESSAGE" \
  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/trigger/pipeline"
