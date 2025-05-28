#!/usr/bin/env bash
# 2025052801

set -e -o pipefail -u -x

rpmdev-setuptree

cp $LFMP_DIR_SOURCES/* ~/rpmbuild/SOURCES/

cp $LFMP_DIR_REPOS/monitoring-plugins/build/linuxfabrik-monitoring-plugins.spec ~/rpmbuild/SPECS/

rpmbuild -bb \
    --define "lf_version $LFMP_VERSION" \
    --define "lf_release $LFMP_PACKAGE_ITERATION" \
    ~/rpmbuild/SPECS/linuxfabrik-monitoring-plugins.spec

cp --archive ~/rpmbuild/RPMS/$LFMP_ARCH/linuxfabrik-monitoring-plugins-*.rpm $LFMP_DIR_PACKAGED
