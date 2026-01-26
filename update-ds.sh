#!/bin/bash
set -e

repo_name=$1
update_rc=$2
update_release=$3

cd .. && git clone {{workflow.parameters.git_pull_prefix}}/$repo_name.git && cd $repo_name

if [[ "{{workflow.parameters.build_type}}" == "rc" ]]; then
  # determine down stream tag and create / switch to rc branch
  new_tag=$(/scripts/get-new-tag.sh {{workflow.parameters.build_increment}})
  git checkout $new_tag-rc || git checkout -b $new_tag-rc

  commit_message=$($update_rc $build_tag) 
  git add .

  git commit -m "$commit_message"
  git push origin $new_tag-rc

elif [[ "{{workflow.parameters.build_type}}" == "release" ]]; then
  # for prod releases we simply commit the new version into the master branch

  # use pessimistic constraint for e2e tests and some flexibility on prod
  PESSIMISTIC_CONSTRAINT=$(/scripts/get-pessimistic-semver.sh $build_tag)
  sed -i "s/^py-pve-cloud>=.*$/py-pve-cloud>=${build_tag},<${PESSIMISTIC_CONSTRAINT}/" requirements.txt
  git add requirements.txt

  git commit -m "Update py-pve-cloud version to $build_tag (pessimistic)"
  git push origin master
fi