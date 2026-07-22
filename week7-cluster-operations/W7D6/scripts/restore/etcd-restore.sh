#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <full-path-to-snapshot>"
    exit 1
fi

SNAPSHOT="$1"

if [[ ! -f "$SNAPSHOT" ]]; then
    echo "Snapshot not found:"
    echo "  $SNAPSHOT"
    exit 1
fi

sudo etcdutl snapshot restore "${SNAPSHOT}" \
  --data-dir=/var/lib/etcd-restored

echo
echo "Restore completed."
echo
echo "Restored data directory:"
echo "/var/lib/etcd-restored"