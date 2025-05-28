#!/usr/bin/env bash
# 2025052801

set -e -o pipefail -u -x

# Debuild wants a specific tarball name
mv $LFMP_DIR_SOURCES/v$LFMP_VERSION.tar.gz $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins_$LFMP_VERSION.orig.tar.gz

mkdir $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins

tar --extract \
    --directory $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins \
    --file $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins_$LFMP_VERSION.orig.tar.gz \
    --ungzip \
    --verbose --verbose \
    --strip 1

mkdir $LFMP_DIR_SOURCES/vendor

tar --extract \
    --directory $LFMP_DIR_SOURCES \
    --file $LFMP_DIR_SOURCES/vendor.tar.gz \
    --ungzip \
    --verbose --verbose

pushd $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins

cp --archive build/debian .

# Dynamically write changelog to inject version and other required metadata.
# Debian's packaging tools read this metadata from this file.
cat <<EOF > debian/changelog
linuxfabrik-monitoring-plugins ($LFMP_VERSION-$LFMP_PACKAGE_ITERATION) unstable; urgency=medium

  * v$LFMP_VERSION release.

 -- Linuxfabrik GmbH, Zurich, Switzerland <info@linuxfabrik.ch>  $(date --rfc-email)
EOF

# debuild params first then dpkg-buildpackage params (cf. debuild(1))
debuild \
    --set-envvar LFMP_DIR_SOURCES=$LFMP_DIR_SOURCES --set-envvar LFMP_PYTHON=$LFMP_PYTHON \
    --build=binary --no-sign

cp --archive $LFMP_DIR_SOURCES/linuxfabrik-monitoring-plugins*.deb $LFMP_DIR_PACKAGED
