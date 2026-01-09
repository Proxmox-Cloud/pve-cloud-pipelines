#!/bin/bash
set -e

# set config based on the current commit for auto commit
git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# determine the new tag based on release-patch/minor/major
new_tag=$(/scripts/get-new-tag.sh)
echo $new_tag

# cleanup delete rc tags
if git ls-remote --heads origin | grep -q "refs/heads/${new_tag}-rc"; then
  echo "deleting rc release branch ${new_tag}-rc"
  git push origin --delete "${new_tag}-rc"
else
  echo "no rc branch found! prod release without rc first?"
fi

# tag and push => created by job ci token, will not trigger the tag released pipeline
git tag "$new_tag" -m "$CI_COMMIT_TAG"
git push origin "$new_tag"

sleep 10 # small buffer for gitlab api

# manually trigger the pipeline that should have been invoked by pushing the tag
# gitlab ci is ass
curl --request POST \
  --form "token=${CI_JOB_TOKEN}" \
  --form "ref=${new_tag}" \
  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/trigger/pipeline"