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

After having build and tested everything locally (using tdd e2e tests), commit all your changes and use the following tags as triggers for a release:

* `release-patch` / `release-minor` / `release-major` 

These tags are reused so we have to force push them for example `git tag -f release-patch && git push -f origin release-patch`.

These tags will release and update all dependant projects, update dependencies and trigger a release there aswell. That means if you made changes to the pve_cloud collection and the py-pve-cloud package, it is enough push a release tag to the package.

## Publish ci image

```bash
docker build . -t tobiashvmz/pve-cloud-ci:latest
docker push tobiashvmz/pve-cloud-ci
```