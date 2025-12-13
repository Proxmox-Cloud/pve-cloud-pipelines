# Gitlab CI Pipelines - pve-cloud-pipelines

This repository contains pipeline definitions used in our private gitlab that is used for building all artifacts of this project.

## Setup CI

* create `PYPI_TOKEN` and `DOCKER_AUTH_CONFIG_B64` gitlab ci variables for the pve-cloud repository group.

The docker auth variable can be formatted using this bash script:

```bash
TOKEN=
USERNAME= # docker hub username

AUTH=$(echo -n "$USERNAME:$TOKEN" | base64)

cat <<EOF | base64 -w 0
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "$USERNAME",
      "password": "$TOKEN",
      "auth": "$AUTH"
    }
  }
}
EOF
```

* add `*.*.*` as protected tag pattern under Repository settings in gitlab for each repository with a pipeline.
* allow job ci tokens to make push changes to the repositories, CI/CD settings => Job token permissions => Allow git push

## Releasing

After having build and tested everything locally (using tdd e2e tests), commit all your changes. Using the following tags you can trigger different kinds of releases.

* `release-patch` / `release-minor` / `release-major` 

These tags are reused so we have to force push them for example `git tag -f release-patch && git push -f origin release-patch`.

These tags will release and update all dependant projects, without triggering a full release there. It will simply update its version and commit.

* `release-all-patch` / `release-all-minor` / `release-all-major` 

Using this will not only update the version but also trigger an equivalent in all the downstream repositories aswell.

## Publish ci image

```bash
VERSION=$(date +"%Y%m%d%H")
docker build . -t tobiashvmz/pve-cloud-ci:$VERSION
docker push tobiashvmz/pve-cloud-ci:$VERSION
```