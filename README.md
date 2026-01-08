# Gitlab CI Pipelines - pve-cloud-pipelines

This repository contains pipeline definitions used in our private gitlab that is used for building all artifacts of this project.

## Setup CI

Gitlab runners need to be priviledged to support podman builds via ci.

* create `PYPI_TOKEN`, `DOCKER_AUTH_CONFIG_B64` and `ANSIBLE_GALAXY_TOKEN` gitlab ci variables for the pve-cloud repository group.

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

### Terraform registry

As the public registry forces github use (...) we need to set `GITHUB_TOKEN` in GITLAB ci and let our ci handle interacting with github.

* create a gpg key signing terraform artifacts

```bash
gpg --full-generate-key # choose (1) RSA and RSA, 4096 size
# take a passphrase with no special characters that might interfere with
# bash scripting

gpg --list-keys # to get the id/fingerprint
# set GPG_FINGERPRINT ci var

gpg --armor --export-secret-keys KEYID # | base64 -w 0 export the private key for use in ci
# also save in secret manager of your choice alongside passphrase
# => add CI variable GPG_EXPORTED_KEY_B64 and GPG_PASSPHRASE
```

## Releasing

After having build and tested everything locally (using tdd e2e tests), commit all your changes. Using the following tags you can trigger different kinds of releases.

* `release-patch` / `release-minor` / `release-major` 

These tags are reused so we have to force push them for example `git pull && git tag -f release-patch && git push -f origin release-patch`. We need to pull first to get changes from the formatting / cleanup pipelines.

These tags will release and update all dependant projects, without triggering a full release there. It will simply update its version and commit.

* `release-all-patch` / `release-all-minor` / `release-all-major` 

Using this will not only update the version but also trigger an equivalent in all the downstream repositories aswell.

If you are unsure what you changed and want to just do a full release of all the artificats, do a normal `release-patch` on `pve-cloud-schemas` followed by a `release-all-patch` on `py-pve-cloud`.

## Publish ci images

```bash
VERSION=$(date +"%Y%m%d%H%M")
docker build -f Dockerfile.ci . -t tobiashvmz/pve-cloud-ci:$VERSION
docker push tobiashvmz/pve-cloud-ci:$VERSION
```

```bash
VERSION=$(date +"%Y%m%d%H%M")
docker build -f Dockerfile.pyci . -t tobiashvmz/pve-cloud-pyci:$VERSION
docker push tobiashvmz/pve-cloud-pyci:$VERSION
```