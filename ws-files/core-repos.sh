#!/bin/bash
set -e

# this includes all repositories that contain the core proxmox cloud collection
# pipelines and forks are not included
DIRS=(
  "terraform-pxc-controller" 
  "terraform-pxc-backup" 
  "terraform-provider-pxc"
  "pve-cloud-schemas"
  "pytest-pve-cloud"
  "py-pve-cloud"
  "pve-cloud-controller"
  "pve-cloud-backup"
  "ansible_collections/pxc/cloud"
)

for dir in "${DIRS[@]}"; do
    (cd "$dir" && eval "$@")
done