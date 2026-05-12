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
# Pick the lockfile that matches the venv's Python. We resolve the
# python interpreter from the pip path (e.g. /opt/venv/bin/pip ->
# /opt/venv/bin/python) instead of relying on $LFMP_PYTHON, because
# during vendor-install we are working *inside* the target venv.
LFMP_VENV_PYTHON="$(dirname "$LFMP_VENV_PIP")/python"
PY_TAG="py$($LFMP_VENV_PYTHON -c 'import sys; print(f"{sys.version_info.major}{sys.version_info.minor}")')"
REQS="requirements-${PY_TAG}.txt"
if [ ! -f "$REQS" ]; then
    echo "❌ No requirements file for Python ${PY_TAG} at $REQS" >&2
    exit 1
fi
$LFMP_VENV_PIP install \
    --no-dependencies \
    --no-index \
    --find-links $LFMP_DIR_SOURCES/vendor \
    --require-hashes \
    --requirement "$REQS"

# Setuptools & Wheel is no longer needed
$LFMP_VENV_PIP uninstall --yes setuptools wheel
