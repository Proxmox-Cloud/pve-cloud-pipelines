#!/bin/bash
set -e

# get existing rc tags
rc_tags=$(git tag -l | grep -E "^$1-rc[0-9]+$" || true)

if [ -z "$rc_tags" ]; then
  rc_vers_tag="$1-rc0"
else
  latest_rc=$(echo "$rc_tags" | sort -V | tail -n 1)
  rc_num=${latest_rc##*-rc}   # removes everything up to last "-rc"
  
  next_rc=$((rc_num + 1))
  
  rc_vers_tag="$1-rc${next_rc}"
fi

echo $rc_vers_tag