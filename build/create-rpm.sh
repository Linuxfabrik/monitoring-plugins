#!/usr/bin/env bash
# 2025101601

set -e -o pipefail -u -x

echo "✅ Setup rpm build tree"
cat <<\EOF >> $HOME/.rpmmacros
%_topdir %(echo $HOME)/rpmbuild

%__arch_install_post \
    [ "%{buildarch}" = "noarch" ] || QA_CHECK_RPATHS=1 ; \
    case "${QA_CHECK_RPATHS:-}" in [1yY]*) /usr/lib/rpm/check-rpaths ;; esac \
    /usr/lib/rpm/check-buildroot
EOF

mkdir --parent $HOME/rpmbuild/BUILD
mkdir --parent $HOME/rpmbuild/RPMS
mkdir --parent $HOME/rpmbuild/SOURCES
mkdir --parent $HOME/rpmbuild/SPECS
mkdir --parent $HOME/rpmbuild/SRPMS

echo "✅ Create rpm"

cp $LFMP_DIR_SOURCES/* ~/rpmbuild/SOURCES/

cp "$1" ~/rpmbuild/SPECS/

rpmbuild -bb \
    --define "lf_version $LFMP_VERSION" \
    --define "lf_release $LFMP_PACKAGE_ITERATION" \
    "$HOME/rpmbuild/SPECS/$(basename "$1")"

cp --archive ~/rpmbuild/RPMS/$LFMP_ARCH/linuxfabrik-monitoring-plugins-*.rpm $LFMP_DIR_PACKAGED
