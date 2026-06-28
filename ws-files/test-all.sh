#!/bin/bash
set -e

echo "__version__ = \"0.0.1\"" > pytest-pve-cloud/src/pve_cloud_test/_version.py
(cd pytest-pve-cloud && pip install -e .)

(cd ansible_collections/pxc/cloud && pytest -s tests/e2e/ --skip-cleanup --skip-runner-tags kubespray) 
(cd terraform-pxc-controller && pytest -s tests/e2e/ --skip-cleanup)
(cd terraform-pxc-backup && pytest -s tests/e2e/ --skip-cleanup)

# kubernetes reset while keeping mirror vm: (cd ansible_collections/pxc/cloud && pytest -s tests/e2e/ --skip-fixture-tags mirror --skip-runner-tags kubespray)
