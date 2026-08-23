# CLI Version Checking - Codebase Scan Findings

## Overview

This task documents every CLI tool usage across the pve-cloud codebase that should have version validation. The existing `setup_control_node.yaml` playbook only validates **kubectl** and **helm** on the control node. The rest of the codebase (Ansible roles, Python source, Go provider) uses many more CLI tools with no version checking whatsoever.

---

## Existing Version Checking (Control Node)

**File:** `ansible_collections/pxc/cloud/playbooks/setup_control_node.yaml`

| Tool | Required Version | Lines |
|------|-----------------|-------|
| `kubectl` | `v1.36.0` | 27-57 |
| `helm` | `v4.2.0` | 60-99 |

Both use the same pattern: check binary exists → run `version` command → parse version → fail on mismatch → download if missing.

---

## CLI Tools Used Across the Codebase

### Category 1: Proxmox VE CLI Tools

These tools are used on Proxmox nodes (not control node) to manage VMs, containers, and cluster operations.

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `qm` | Ansible roles: `bootstrap_vm`, `generate_cinit_net_cfg`. Playbooks: `destroy_qemus`, `sync_qemus`, `sync_kubespray`, `destroy_kubespray` | ~20 usages | No |
| `pct` | Ansible roles: `bootstrap_lxc`. Playbooks: `destroy_lxcs`, `sync_lxcs` | ~10 usages | No |
| `pvesh` | Ansible roles: `determine_vms_create_delete`, `bootstrap_vm`, `bootstrap_lxc`. Playbooks: `destroy_qemus`, `destroy_lxcs`, `destroy_kubespray`, `sync_qemus`, `sync_lxcs`, `sync_kubespray`. Python: `plugins/module_utils/inventory.py` | ~15 usages | No |
| `pveam` | Ansible role: `bootstrap_lxc` | 1 usage | No |

**Files:**
- `ansible_collections/pxc/cloud/roles/bootstrap_vm/tasks/main.yml` — `qm create`, `qm set`, `qm start`
- `ansible_collections/pxc/cloud/roles/bootstrap_vm/tasks/generate_cinit_net_cfg.yml` — `qm config`
- `ansible_collections/pxc/cloud/roles/bootstrap_lxc/tasks/main.yml` — `pct create`, `pct set`, `pct start`, `pct list`, `pct config`
- `ansible_collections/pxc/cloud/roles/determine_vms_create_delete/tasks/main.yml` — `pvesh get /cluster/resources`
- `ansible_collections/pxc/cloud/roles/set_memory_facts/tasks/main.yml` — `qm list`, `qm config`, `pct list`, `pct config`
- `ansible_collections/pxc/cloud/playbooks/destroy_qemus.yaml` — `qm stop`, `qm status`, `qm destroy`
- `ansible_collections/pxc/cloud/playbooks/destroy_lxcs.yaml` — `pct stop`, `pct status`, `pct destroy`
- `ansible_collections/pxc/cloud/playbooks/destroy_kubespray.yaml` — `qm stop`, `qm status`, `qm destroy`
- `ansible_collections/pxc/cloud/playbooks/sync_qemus.yaml` — `qm stop`, `qm status`, `qm destroy`
- `ansible_collections/pxc/cloud/playbooks/sync_lxcs.yaml` — `pct stop`, `pct status`, `pct destroy`
- `ansible_collections/pxc/cloud/playbooks/sync_kubespray.yaml` — `qm stop`, `qm status`, `qm destroy`, `qm set --delete`, `pvesh get /cluster/resources`
- `ansible_collections/pxc/cloud/plugins/module_utils/inventory.py` — `pvesh get /cluster/resources`, `pvesh get /cluster/ha/groups`, `pvesh get /nodes/{node}/qemu/{vmid}/agent/network-get-interfaces`

---

### Category 2: Ceph / RBD Tools

Used exclusively in the backup system for RBD image management and Ceph pool operations.

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `rbd` | Python: `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py`, `daemon/restore.py` | ~12 usages | No |
| `ceph` | Ansible: `roles/slurp_cluster_secrets`. Python: `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py` | 3 usages | No |

**Files:**
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:126` — `rbd group create`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:143` — `rbd group image add`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:165` — `rbd snap ls`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:189` — `rbd clone`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:213` — `rbd group snap create`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:362` — `rbd rm`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:376` — `rbd group snap rm`
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/funcs.py:390` — `rbd group rm`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py:769` — `rbd import`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py:830` — `rbd rm`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py:841` — `rbd import`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/restore.py:259` — `ceph osd pool ls detail`
- `ansible_collections/pxc/cloud/roles/slurp_cluster_secrets/tasks/main.yml:35` — `ceph fsid`

---

### Category 3: Backup Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `borg` | Python: `pve-cloud-backup/src/pve_cloud_backup/daemon/funcs.py`, `daemon/bdd.py` | ~7 usages | No |

**Files:**
- `pve-cloud-backup/src/pve_cloud_backup/daemon/funcs.py:34` — `borg init`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/funcs.py:68` — `borg list`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py:101` — `borg create`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py:180` — `borg delete`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py:329` — `borg extract`

---

### Category 4: Container & Image Registry Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `skopeo` | Ansible: `roles/mirror_container_image`, `roles/mirror_helm_chart`. Python: `pve-cloud-controller/src/pve_cloud_ctrl/pod_watcher.py`, `adm.py`. Go: `terraform-provider-pxc/internal/provider/helm_mirror_resource.go` | ~7 usages | No |
| `docker` | Python: `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py`. Ansible: `playbooks/sync_kubespray.yaml` (pipe lookup) | 3 usages | No |
| `helm` | Ansible: `roles/mirror_helm_chart`. Go: `terraform-provider-pxc/internal/provider/helm_mirror_resource.go` | ~6 usages | Only on control node |

**Files:**
- `ansible_collections/pxc/cloud/roles/mirror_container_image/tasks/main.yml` — `skopeo inspect`, `skopeo copy`
- `ansible_collections/pxc/cloud/roles/mirror_helm_chart/tasks/main.yml` — `skopeo inspect --raw`, `helm repo add`, `helm repo update`, `helm pull`, `helm push`
- `pve-cloud-controller/src/pve_cloud_ctrl/pod_watcher.py:82` — `skopeo copy`
- `pve-cloud-controller/src/pve_cloud_ctrl/adm.py:75` — `skopeo inspect --raw`
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:174` — `skopeo inspect --raw`
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:302` — `helm repo add`
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:310` — `helm repo update`
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:319` — `helm pull`
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:328` — `helm pull` (OCI)
- `terraform-provider-pxc/internal/provider/helm_mirror_resource.go:336` — `helm push`

---

### Category 5: Package Management Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `apt` | Ansible: `roles/vector_journald_exporter`, `roles/setup_pxzfs_localpv_zpool`, `playbooks/setup_postgres`, `playbooks/setup_kea`, `playbooks/setup_ceph_kea` | ~7 usages | No |
| `pip` | Ansible: `playbooks/setup_postgres`. Python: `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py`. Go: `terraform-provider-pxc/internal/provider/provider.go` | 3 usages | No |
| `dkms` | Ansible: `roles/setup_pxzfs_localpv_zpool` | 1 usage | No |

**Files:**
- `ansible_collections/pxc/cloud/roles/vector_journald_exporter/tasks/main.yml:94` — `apt update`, `apt install`
- `ansible_collections/pxc/cloud/roles/setup_pxzfs_localpv_zpool/tasks/main.yml:32` — `dkms autoinstall`
- `ansible_collections/pxc/cloud/playbooks/setup_postgres.yaml:54` — `pip install patroni`
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py:365` — `pip install`
- `terraform-provider-pxc/internal/provider/provider.go:284` — `pip install grpc-pve-cloud`

---

### Category 6: System Management Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `systemctl` | Ansible: `roles/alternate_ssh_port`, `roles/btrfs_prom_exporter` | 3 usages | No |
| `journalctl` | Ansible: `roles/install_log2ram` | 1 usage | No |

**Files:**
- `ansible_collections/pxc/cloud/roles/alternate_ssh_port/tasks/main.yml:11` — `systemctl mask`, `systemctl disable`, `systemctl enable`
- `ansible_collections/pxc/cloud/roles/btrfs_prom_exporter/tasks/main.yml:15` — `systemctl daemon-reload`
- `ansible_collections/pxc/cloud/roles/install_log2ram/tasks/main.yml:15` — `journalctl --vacuum-size`

---

### Category 7: Network & Data Transfer Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `rsync` | Ansible: `playbooks/sync_kubespray`. Python: `pytest-pve-cloud/src/pve_cloud_test/terraform.py` | 4 usages | No |
| `curl` | Ansible: `playbooks/setup_kea`, `playbooks/setup_ceph_kea`, `roles/vector_journald_exporter` | 4 usages | No |
| `avahi-browse` | Python: `py-pve-cloud/src/pve_cloud/lib/inventory.py` | 1 usage | No |

**Files:**
- `ansible_collections/pxc/cloud/playbooks/sync_kubespray.yaml:254` — `rsync -avz`
- `ansible_collections/pxc/cloud/playbooks/sync_kubespray.yaml:333` — `rsync -avz`
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py:116` — `rsync -avz`
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py:121` — `rsync -avz`
- `ansible_collections/pxc/cloud/playbooks/setup_kea.yaml:71` — `curl`
- `ansible_collections/pxc/cloud/playbooks/setup_ceph_kea.yaml:20` — `curl`
- `ansible_collections/pxc/cloud/roles/vector_journald_exporter/tasks/main.yml:94` — `curl`
- `py-pve-cloud/src/pve_cloud/lib/inventory.py:30` — `avahi-browse -rpt _pxc._tcp`

---

### Category 8: Cryptography & DNS Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `openssl` | Ansible: `playbooks/setup_pve_clusters` | 4 usages | No |
| `tsig-keygen` | Ansible: `playbooks/setup_pve_clusters` | 1 usage | No |

**Files:**
- `ansible_collections/pxc/cloud/playbooks/setup_pve_clusters.yaml:306` — `tsig-keygen internal.`
- `ansible_collections/pxc/cloud/playbooks/setup_pve_clusters.yaml:314` — `openssl genrsa`, `openssl req -x509`, `openssl x509 -req`
- `ansible_collections/pxc/cloud/playbooks/setup_pve_clusters.yaml:337` — `openssl rand -base64`
- `ansible_collections/pxc/cloud/playbooks/setup_pve_clusters.yaml:344` — `openssl rand -base64`
- `ansible_collections/pxc/cloud/playbooks/setup_pve_clusters.yaml:351` — `openssl genrsa`

---

### Category 9: Disk & Block Device Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `lsblk` | Ansible: `playbooks/sync_kubespray` | 1 usage | No |
| `grep`, `awk` | Ansible: `roles/set_memory_facts`, `roles/slurp_cluster_secrets` | ~4 usages | No |

**Files:**
- `ansible_collections/pxc/cloud/playbooks/sync_kubespray.yaml:385` — `lsblk --json -o NAME,PATH,SERIAL,FSTYPE`
- `ansible_collections/pxc/cloud/roles/set_memory_facts/tasks/main.yml:3` — `qm list`, `awk`, `grep`, `qm config`, `awk`
- `ansible_collections/pxc/cloud/roles/slurp_cluster_secrets/tasks/main.yml:47` — `grep`, `awk`

---

### Category 10: Version Control & Build Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `git` | Python: `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py`, `pve-cloud-backup/src/pve_cloud_backup/fetcher/git.py` | 4 usages | No |

**Files:**
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py:22` — `git tag`
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py:30` — `git branch --show-current`
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py:142` — `git clone` (build command)
- `pytest-pve-cloud/src/pve_cloud_test/tdd_watchdog.py:250` — `git clone` (build command)
- `pve-cloud-backup/src/pve_cloud_backup/fetcher/git.py:18` — `git clone`

---

### Category 11: APT Mirror & Package Repository Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `aptly` | Ansible: `roles/aptly_mirror_repo` | 13 usages | No |

**Files:**
- `ansible_collections/pxc/cloud/roles/aptly_mirror_repo/tasks/main.yml` — `aptly mirror list`, `aptly mirror create`, `aptly mirror update`, `aptly snapshot create`, `aptly publish snapshot`, `aptly mirror show`, `aptly mirror edit`, `aptly publish drop`, `aptly snapshot drop`

---

### Category 12: Miscellaneous Tools

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `cat` | Python: `py-pve-cloud/src/pve_cloud/cli/pxrpc.py`. Ansible: `plugins/module_utils/inventory.py` | 4 usages | No |
| `pcrpc` | Go: `terraform-provider-pxc/internal/provider/provider.go` | 1 usage | No |
| `bash` | Ansible: `roles/vector_journald_exporter`, `playbooks/setup_kea`, `playbooks/setup_ceph_kea` | 4 usages | No |
| `zstd` | Python: `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py` | 1 usage | No |

**Files:**
- `py-pve-cloud/src/pve_cloud/cli/pxrpc.py:102` — `cat /etc/pve/cloud/cluster_vars.yaml`
- `py-pve-cloud/src/pve_cloud/cli/pxrpc.py:115` — `cat /etc/pve/cloud/secrets/patroni.pass`
- `py-pve-cloud/src/pve_cloud/cli/pxrpc.py:126` — `cat /etc/pve/cloud/secrets/internal.key`
- `ansible_collections/pxc/cloud/plugins/module_utils/inventory.py:100` — `cat /etc/pve/cloud/cluster_vars.yaml`
- `terraform-provider-pxc/internal/provider/provider.go:302` — `pcrpc`
- `pve-cloud-backup/src/pve_cloud_backup/daemon/bdd.py:101` — `borg create --compression zstd,1`

---

### Category 13: Terraform CLI (Test Framework)

| Tool | Where Used | Frequency | Version Check? |
|------|-----------|-----------|----------------|
| `terraform` | Python: `pytest-pve-cloud/src/pve_cloud_test/terraform.py` | 3 usages | No |

**Files:**
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py:158` — `terraform init --upgrade`
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py:166` — `terraform apply -auto-approve`
- `pytest-pve-cloud/src/pve_cloud_test/terraform.py:209` — `terraform destroy -auto-approve`

---

## Summary Statistics

| Category | Tool Count | Total Usages | Has Version Check |
|----------|-----------|--------------|-------------------|
| Proxmox VE CLI | 4 | ~46 | No |
| Ceph / RBD | 2 | 13 | No |
| Backup Tools | 1 | 7 | No |
| Container & Image | 3 | 15 | Partial (helm only on control node) |
| Package Management | 3 | 11 | No |
| System Management | 2 | 4 | No |
| Network & Data Transfer | 3 | 8 | No |
| Cryptography & DNS | 2 | 5 | No |
| Disk & Block Device | 3 | 5 | No |
| Version Control | 1 | 4 | No |
| APT Repository | 1 | 13 | No |
| Miscellaneous | 4 | 10 | No |
| Terraform | 1 | 3 | No |
| **Total** | **30 unique tools** | **~144 usages** | **2 of 30 (kubectl, helm on control node only)** |

---

## Key Observations

1. **Huge gap in coverage**: 30 unique CLI tools are used, but only 2 (kubectl, helm) have version checking — and only on the control node playbook, not on the Proxmox nodes where most tools run.

2. **Most critical tools without version checking**:
   - `qm`, `pct`, `pvesh` — core Proxmox management tools used throughout
   - `rbd`, `ceph` — used in backup operations; version mismatches could corrupt data
   - `borg` — backup tool; API changes between versions could break restore flows
   - `skopeo` — used in controller, ansible, and terraform provider; image operations depend on version
   - `helm` — used in ansible roles and Go provider, not just control node

3. **Python source code** has zero version checking for subprocess calls. All `subprocess.run()` and `asyncio.create_subprocess_exec()` calls launch tools without verifying versions first.

4. **Go terraform provider** has zero version checking. All `exec.Command()` calls launch tools without verifying versions first.

5. **Ansible roles** running on Proxmox nodes have zero version checking. The `setup_control_node.yaml` only covers the ansible controller machine, not the target Proxmox nodes where `qm`, `pct`, `pvesh`, `apt`, `systemctl` etc. run.

6. **Test framework** (`pytest-pve-cloud`) uses `terraform`, `docker`, `git`, `pip` via subprocess with no version validation before test execution.
