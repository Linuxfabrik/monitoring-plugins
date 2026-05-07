#!/usr/bin/env bash
# 2026050701

set -e -o pipefail -u -x

echo "✅ Create package for $LFMP_TARGET_DISTRO"
case "$LFMP_TARGET_DISTRO" in
debian-v11 | debian-v12 | debian-v13 | ubuntu-v2204 | ubuntu-v2404 | ubuntu-v2604)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-deb.sh
    ;;
rocky-v8)
    export LFMP_PYTHON=python3.9

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.el.spec
    ;;
rocky-v9 | rocky-v10)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.el.spec
    ;;
sles-v15)
    export LFMP_PYTHON=python3.11

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.sle.spec
    ;;
sles-v16)
    export LFMP_PYTHON=python3

    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-src-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-vendor-tarball.sh
    bash $LFMP_DIR_REPOS/monitoring-plugins/build/create-rpm.sh $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.sle.spec
    ;;
ubuntu-v2004)
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
