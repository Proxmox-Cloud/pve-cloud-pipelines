# Agent Instructions

## Environment Setup

**Always source `.envrc` and the Python virtual environment as the very first step before running any other commands.** This sets all required environment variables including `ANSIBLE_COLLECTIONS_PATH`, test config paths, and activates the Python virtual environment:

```bash
source .envrc
source ../.pve-cloud-dev-venv/bin/activate
```

## Python & Ansible Environment

With the virtual environment activated, all Python commands including `python`, `pip`, `ansible`, `ansible-playbook`, and `ansible-galaxy` are available directly. For example:

```bash
python
pip
ansible
ansible-playbook
ansible-galaxy
pytest
tddog
```


## Running Tests / Validation

For testing you should exclusively rely on the e2e testing suite of this project. Do not create dummy test files / playbooks, find the best existing test case and run it.

Always pass the flag `--skip-cleanup` to any `pytest` command you execute. Tests always live in the `tests/e2e` folder and are run from the repositories root directory

The only repositories holding tests are the following:

- `ansible_collections/pxc/cloud`
- `terraform-pxc-backup`
- `terraform-pxc-controller`

However build artifacts are held by various projects and can be build individual with the custom cli tool `tddog --oneshot`, run this command after making changes in the root folder of the repository, assuming there is a `tddog.toml` present in the repository, if not there are not artifacts that need to be build.

If you made changes to multiple source repositories, simply run `tddog --recursive --oneshot` once from the directory you were startet in. This will automatically detect and build all repositories in order. 

**Only run the needed tests.** Our custom pytest cli options provide the ability to skip fixtures / tags of playbooks that are not needed to validate a change. Always target the most fitting test functions (never the whole folder) and trim fixture execution with the custom tag CLI options:

```bash
# example for testing the creation of the bind lxc containers + setup of the bind dns server 
(cd ansible_collections/pxc/cloud && pytest -s tests/e2e/test_cloud.py::test_bind --skip-cleanup --fixture-tags bind)

# the create and setup of patroni lxc stack, while skipping all other irrelevant previous setup fixtures (e2e system is always already deployed)
(cd ansible_collections/pxc/cloud && pytest -s tests/e2e/test_cloud.py::test_patroni --skip-cleanup --fixture-tags postgres)

# test the creation and configuration of a test k0s kubernetes system
(cd ansible_collections/pxc/cloud && pytest -s tests/e2e/test_cloud.py::test_create_k0s_edge --fixture-tags k0s --skip-cleanup)

# test backup restore procedures, specific to the k0s system, skipping all other backup cases
(cd terraform-pxc-backup && pytest -s tests/e2e/test_backup.py::test_restore_k0s --skip-cleanup --fixture-tags k0s-tf)

# test the custom terraform providers functionality to connect / initialize the kubernetes terraform provider for k0s system
(cd terraform-pxc-controller && pytest -s tests/e2e/test_modules.py::test_k0s_provider_connect --skip-cleanup)
```

You should always assume that there is a already deployed test system running and that you only work on specific features.

### Custom pytest CLI options

Defined in `pytest-pve-cloud/src/pve_cloud_test/options.py` (loaded via `pytest_plugins` in each e2e `conftest.py`):

| Option | Effect |
|---|---|
| `--skip-cleanup` | Skips fixture and test teardown, keeps infra state for consecutive runs |
| `--skip-fixtures` | Skips all fixtures entirely, runs tests against already deployed infra |
| `--fixture-tags a,b` | Only executes `cloud_fixture` fixtures tagged with at least one of a,b |
| `--skip-fixture-tags a,b` | Skips `cloud_fixture` fixtures tagged with at least one of a,b (exclusive with `--fixture-tags`) |
| `--runner-tags a,b` | Passes `--tags` to ansible playbooks run inside fixtures |
| `--skip-runner-tags a,b` | Passes `--skip-tags` to ansible playbooks (exclusive with `--runner-tags`) |
| `--ansible-verbosity 1..3` | ansible runner log verbosity (default 0) |


## Repository Scope

**Only work within these 8 repositories.** Do not modify, read, or reference any other repos or directories outside of them:

| # | Repository | Path |
|---|---|---|
| 1 | `ansible_collections/pxc/cloud` | `ansible_collections/pxc/cloud/` |
| 2 | `py-pve-cloud` | `py-pve-cloud/` |
| 3 | `pytest-pve-cloud` | `pytest-pve-cloud/` |
| 4 | `terraform-pxc-backup` | `terraform-pxc-backup/` |
| 5 | `terraform-pxc-controller` | `terraform-pxc-controller/` |
| 6 | `pve-cloud-controller` | `pve-cloud-controller/` |
| 7 | `pve-cloud-backup` | `pve-cloud-backup/` |
| 8 | `terraform-provider-pxc` | `terraform-provider-pxc/` |

When you work with a repository, check if it contains its own AGENTS.md file and read it if present.

### Code Directories Only

When scanning or modifying files, only operate on the above mentioned directories. Exclude all build, cache, artifact, and non-source directories:

**Excluded directories (never read or modify):**
`.git`, `__pycache__`, `.pytest_cache`, `.terraform`, `dist`, `*.egg-info`

**Valid code directories per repo:**

| Repo | Code Directories |
|---|---|
| `ansible_collections/pxc/cloud` | `plugins/`, `roles/`, `playbooks/`, `meta/`, `docs/`, `json-schema-humans-custom/`, `tests/` |
| `py-pve-cloud` | `src/` |
| `pytest-pve-cloud` | `src/` |
| `terraform-pxc-backup` | `modules/`, `templates/`, root `.tf` files, `tests/` |
| `terraform-pxc-controller` | `modules/`, root `.tf` files, `tests/` |
| `pve-cloud-controller` | `src/` |
| `pve-cloud-backup` | `src/` |
| `terraform-provider-pxc` | `internal/`, `src/`, `protos/`, `templates/`, root `main.go` |
