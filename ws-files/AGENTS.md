# Agent Instructions

## Environment Setup

**Always source `.envrc` and the Python virtual environment as the very first step before running any other commands.** This sets all required environment variables including `ANSIBLE_COLLECTIONS_PATH`, test config paths, and activates the Python virtual environment:

```bash
source .envrc
source ~/.pve-cloud-dev-venv/bin/activate
```

## Python & Ansible Environment

With the virtual environment activated, all Python commands including `python`, `pip`, `ansible`, `ansible-playbook`, and `ansible-galaxy` are available directly. For example:

```bash
python
pip
ansible
ansible-playbook
ansible-galaxy
```

## Running Tests

Before running any tests always execute `tddog --recursive --oneshot` once in the root project dir, this will build all artifacts used by the testing suite.

## Repository Scope

**Only work within these 5 repositories.** Do not modify, read, or reference any other repos or directories outside of them:

| # | Repository | Path |
|---|---|---|
| 1 | `ansible_collections/pxc/cloud` | `ansible_collections/pxc/cloud/` |
| 2 | `py-pve-cloud` | `py-pve-cloud/` |
| 3 | `pytest-pve-cloud` | `pytest-pve-cloud/` |
| 4 | `terraform-pxc-backup` | `terraform-pxc-backup/` |
| 5 | `terraform-pxc-controller` | `terraform-pxc-controller/` |

### Code Directories Only

When scanning or modifying files, only operate on these code directories. Exclude all build, cache, artifact, and non-source directories:

**Excluded directories (never read or modify):**
`.cache`, `__pycache__`, `.venv`, `node_modules`, `.terraform`, `.git`, `.pytest_cache`, `.mypy_cache`, `.tox`, `dist`, `build`, `*.egg-info`, `.ansible`, `.vscode`, `.idea`, `.cargo`, `.context7`, `.dotnet`, `.kube`, `.local`, `.gnupg`, `.docker`, `.agents`, `*.tgz`, `*.tar`, `*.zip`, `*.pyc`, `*.pyo`, `*.so`, `*.pyd`, `*.o`, `*.a`, `*.lib`, `*.dylib`, `*.class`, `*.jar`, `*.war`, `*.ear`, `*.whl`, `.eggs`, `.nox`, `htmlcov`, `.coverage`, `coverage.xml`, `.ruff_cache`, `.mypy_cache`, `__pycache__`, `.tox`, `.pytest_cache`, `.benchmarks`, `.hypothesis`, `.cache`, `cache`, `.bundle`, `.gems`, `vendor`, `tmp`, `temp`, `test-output`, `reports`, `artifacts`, `logs`, `*.log`

**Valid code directories per repo:**

| Repo | Code Directories |
|---|---|
| `ansible_collections/pxc/cloud` | `plugins/`, `roles/`, `playbooks/`, `meta/`, `docs/`, `json-schema-humans-custom/` |
| `py-pve-cloud` | `src/` |
| `pytest-pve-cloud` | `src/` |
| `terraform-pxc-backup` | `modules/`, `templates/`, root `.tf` files |
| `terraform-pxc-controller` | `modules/`, root `.tf` files |
