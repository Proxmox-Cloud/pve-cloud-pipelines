# CLI Version Checking — Quick Reference

## The Problem

The codebase uses **30 unique CLI tools** across Ansible playbooks, Python source, and Go code, but only **2 tools** (kubectl, helm) have version checks — and only in the control node setup playbook, not on the target nodes where the tools actually run.

## Tools Without Any Version Check (28 tools)

### Must-have for Proxmox operations
- `qm` — VM management (~20 usages)
- `pct` — LXC container management (~10 usages)
- `pvesh` — Proxmox API CLI (~15 usages)
- `pveam` — Proxmox VE Asset Manager (1 usage)

### Must-have for backup operations
- `rbd` — Ceph RBD CLI (~12 usages)
- `ceph` — Ceph CLI (3 usages)
- `borg` — BorgBackup (~7 usages)

### Must-have for image/charts
- `skopeo` — Container image tool (~7 usages)
- `helm` — Helm chart tool (~6 usages, **only checked on control node**)

### Must-have for provisioning
- `apt` — APT package manager (~7 usages)
- `pip` — Python package manager (3 usages)
- `docker` — Docker CLI (3 usages)
- `systemctl` — Systemd manager (3 usages)

### Supporting tools
- `rsync`, `curl`, `git`, `terraform`, `kubectl`, `lsblk`, `openssl`, `tsig-keygen`, `aptly`, `dkms`, `journalctl`, `avahi-browse`, `cat`, `pcrpc`, `bash`, `zstd`

## Where Tools Are Used

| Location | Count | Has Version Check? |
|----------|-------|--------------------|
| Ansible roles on Proxmox nodes | ~90 usages | No |
| Ansible playbooks | ~40 usages | No |
| Python source (4 repos) | ~35 usages | No |
| Go terraform provider | ~10 usages | No |
| Control node setup only | 2 tools | Yes |

## Existing Pattern (from setup_control_node.yaml)

The control node playbook uses this pattern for kubectl/helm:
1. `stat` — check if binary exists
2. `command` — run `<tool> version`
3. `regex_search` — parse version string
4. `fail` — abort if version mismatch
5. `get_url`/`unarchive` — download correct version if missing

This pattern should be extended to cover all 30 tools, with version checks placed:
- **On control node**: kubectl, helm, skopeo, rsync
- **On Proxmox nodes**: qm, pct, pvesh, pveam, rbd, ceph, apt, systemctl, borg, skopeo, aptly, etc.
- **In Python code**: validate before subprocess calls
- **In Go code**: validate before exec.Command calls

## Files to Modify

### Ansible (add version check roles/tasks)
- `roles/bootstrap_vm/tasks/main.yml` — qm version check before use
- `roles/bootstrap_lxc/tasks/main.yml` — pct version check before use
- `roles/aptly_mirror_repo/tasks/main.yml` — aptly version check
- `roles/mirror_container_image/tasks/main.yml` — skopeo version check
- `roles/mirror_helm_chart/tasks/main.yml` — helm version check
- `roles/slurp_cluster_secrets/tasks/main.yml` — ceph version check
- `playbooks/setup_pve_clusters.yaml` — openssl/tsig-keygen version check
- All other roles and playbooks with shell/command usages

### Python (add version validation helpers)
- `py-pve-cloud/src/pve_cloud/cli/pxrpc.py` — validate before subprocess
- `py-pve-cloud/src/pve_cloud/lib/inventory.py` — validate avahi-browse
- `pve-cloud-controller/src/pve_cloud_ctrl/pod_watcher.py` — validate skopeo
- `pve-cloud-controller/src/pve_cloud_ctrl/adm.py` — validate skopeo
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py` — validate rbd
- `pve-cloud-backup/src/pve_cloud_backup/daemon/funcs.py` — validate borg
- `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py` — validate rbd, ceph
- `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py` — validate borg
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py` — validate git, docker, pip
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py` — validate terraform, rsync

### Go (add version validation)
- `terraform-provider-pxc/internal/provider/provider.go` — validate pip, pcrpc
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go` — validate skopeo, helm
