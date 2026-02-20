#!/usr/bin/env bash
# 2025101701

set -e -o pipefail -u -x

echo "✅ Create package for $LFMP_TARGET_DISTRO"
case "$LFMP_TARGET_DISTRO" in
debian11 | debian12 | debian13 | ubuntu2204 | ubuntu2404)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-deb.sh
    ;;
rocky8)
    export LFMP_PYTHON=python3.9

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.el.spec
    ;;
rocky9 | rocky10)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.el.spec
    ;;
sle15)
    export LFMP_PYTHON=python3.11

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.sle.spec
    ;;
sle16)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.sle.spec
    ;;
ubuntu2004)
    # (System) Python 3.9 on Ubuntu 20.04 does not have Pip
    # so we must use a (temporary) venv to download the packages.
    python3.9 -m venv /opt/lfmp-vendordl-venv
    export LFMP_PYTHON=/opt/lfmp-vendordl-venv/bin/python3
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    rm --recursive /opt/lfmp-vendordl-venv

    export LFMP_PYTHON=python3.9
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-deb.sh

    ;;
*)
    echo "Unsupported target distro"
    exit 1
    ;;
esac
