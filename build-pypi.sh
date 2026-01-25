#!/bin/bash
set -e

version=$1
package_name=$2
src_folder=$3

echo "__version__ = \"${1//-/}\"" > src/$src_folder/_version.py
python3 -m build
python3 -m twine upload dist/* -u __token__ -p $PYPI_TOKEN

for i in {1..60}; do
  if curl -s https://pypi.org/simple/$package_name/ | grep -q "${package_name//-/_}-${1//-/}.tar.gz"; then
    echo "exists!"
    exit 0
  fi
  echo "Waiting… ($i/60)"
  sleep 10
done
echo "timeout!"
exit 1

