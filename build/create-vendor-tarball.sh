#!/usr/bin/env bash
# 2025060201

set -e -o pipefail -u -x

echo "✅ Create vendor tarball"

mkdir --parent $LFMP_DIR_REPOS/vendor
mkdir --parent $LFMP_DIR_SOURCES

$LFMP_PYTHON -m pip download \
    --dest $LFMP_DIR_REPOS/vendor \
    setuptools wheel

# Do not download dependencies that are not explicitly pinned using --no-dependencies.
# This fixes the problem that openstack's pbr library unfortunately specifies setuptools
# as a unpinned dependency (which is already downloaded in the previous step).
# All dependencies including hashes are already listed in our requirements anyway.
$LFMP_PYTHON -m pip download \
    --dest $LFMP_DIR_REPOS/vendor \
    --no-dependencies \
    --require-hashes \
    --requirement $LFMP_DIR_REPOS/monitoring-plugins/requirements.txt

tar --create \
    --directory $LFMP_DIR_REPOS \
    --file $LFMP_DIR_SOURCES/vendor.tar.gz \
    --gzip \
    --verbose --verbose \
    vendor
