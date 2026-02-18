# Gitlab CI Pipelines - pve-cloud-pipelines

This repository contains images used for building proxmox cloud. For the main work we rely on argo workflows which is invoked by gitlab ci.

## Setup CI

You need to configure your argo workflows instance somewhere and generate a kubeconfig for access to it.

Alongside the deployment create a k8s secret named `pxc-ci-secrets` with the following fields:

* `id_ed25519` => ssh key used for pulling and pushing to gitlab
* `pypi_token`
* `ansible_galaxy_token`
* `docker_auth_config_b64`
* `gpg_exported_key_b64`
* `gpg_fingerprint`
* `gpg_passphrase
`
In the gitlab group containing the repositories for proxmox cloud, create a CI/CD variable named `ARGO_KUBECONFIG` with the kubeconfig used for submitting the workflow.

### Obtaining secrets

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

* add `release-*` and `rc-` as protected tag pattern under Repository settings in gitlab for each repository with a pipeline.
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

All builds, rcs and full releases are triggered via this projects gitlab ci. You have to manually invoke the pipeline via the gitlab ui and specify your parameters.

! An rc-patch needs to be followed by and release-patch. There are no guardrails!

The project [pve-cloud-schemas](https://github.com/Proxmox-Cloud/pve-cloud-schemas) does not have rc pipelines and also doesnt trigger any downstream builds.

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

```bash
VERSION=$(date +"%Y%m%d%H%M")
docker build -f Dockerfile.goci . -t tobiashvmz/pve-cloud-goci:$VERSION
docker push tobiashvmz/pve-cloud-goci:$VERSION
```

```bash
VERSION=$(date +"%Y%m%d%H%M")
docker build -f Dockerfile.pdci . -t tobiashvmz/pve-cloud-pdci:$VERSION
docker push tobiashvmz/pve-cloud-pdci:$VERSION
```