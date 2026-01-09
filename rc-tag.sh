#!/bin/bash
set -e

# set config based on the current commit for auto commit
git config --global user.name "$GITLAB_USER_NAME"
git config --global user.email "$GITLAB_USER_EMAIL"

# determine the new tag based on rc-patch/minor/major
new_tag=$(/scripts/get-new-tag.sh)
echo $new_tag

# switch to rc branch
/scripts/rc-branch.sh $new_tag

# create new rc release tag and propagate
rc_tags=$(git tag -l | grep -E "^$new_tag-rc[0-9]+$" || true)

if [ -z "$rc_tags" ]; then
  rc_vers_tag="$new_tag-rc0"
else
  latest_rc=$(echo "$rc_tags" | sort -V | tail -n 1)
  rc_num=${latest_rc##*-rc}   # removes everything up to last "-rc"
  
  next_rc=$((rc_num + 1))
  
  rc_vers_tag="$new_tag-rc${next_rc}"
fi

echo $rc_vers_tag

# rc tag and push
git tag "${rc_vers_tag}" -m "$CI_COMMIT_TAG" # again save the initial rc tag for propagation
git push origin "${rc_vers_tag}"

sleep 10

# trigger rc build
curl --request POST \
  --form "token=${CI_JOB_TOKEN}" \
  --form "ref=${rc_vers_tag}" \
  "${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/trigger/pipeline"
