#!/usr/bin/env bash
# 2025052801

set -e -o pipefail -u -x

$LFMP_VENV_PIP install \
    --no-index \
    --find-links $LFMP_DIR_SOURCES/vendor \
    setuptools wheel

# Do not install dependencies that are not explicitly pinned using --no-dependencies.
# This fixes the problem that openstack's pbr library unfortunately specifies setuptools
# as a unpinned dependency (which is already installed in the previous step).
# All dependencies including hashes are already listed in our requirements anyway.
$LFMP_VENV_PIP install \
    --no-dependencies \
    --no-index \
    --find-links $LFMP_DIR_SOURCES/vendor \
    --require-hashes \
    --requirement requirements.txt

# Setuptools & Wheel is no longer needed
$LFMP_VENV_PIP uninstall --yes setuptools wheel
