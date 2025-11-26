
## Publishing / CI

After having successfully tested, there are gitlab pipelines for publishing to official registries (this section now is only relevant for maintainers). Please read the [Contributing Section](./contributing.md) and open a pr.

All projects come with gitlab ci pipelines that trigger into required downstream repos.

### Setup CI

* create `PYPI_TOKEN` and `DOCKER_AUTH_CONFIG_B64` gitlab ci variables for the pve-cloud repository group.

the docker auth variable can be formatted using this bash script:

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

### Releasing

after having build and tested everything locally (using tdd e2e tests), commit all your changes and use the following tags as triggers for a release:

* `release-patch` / `release-minor` / `release-major` 

these tags are reused so we have to force push them for example `git tag -f release-patch && git push -f origin release-patch`.

these tags will release and update all dependant projects, update dependencies and trigger a release there aswell, meaning if you made changes to the pve_cloud collection and the py-pve-cloud package, it is enough push a release tag to the package.

