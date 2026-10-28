#!/usr/bin/env bash
# 2026102802

# Build the source zip for download.linuxfabrik.ch from a checkout of the
# release tag (default: the checkout this script lives in):
# lfmp-<version>-<iteration>.source.noarch.zip in the current directory.
#
# The zip is a standalone source install for `install-monitoring-plugins --zip`:
# every check and notification plugin flat in one directory, their assets, the
# snmp OID lists and MIBs, the lockfiles, and the linuxfabrik-lib the lockfiles
# pin, so nothing is fetched from PyPI at install time.
#
# Usage: build/create-source-zip.sh <version> <iteration> [<checkout>]

set -e -o pipefail -u

VERSION="$1"
ITERATION="$2"

REPO_DIR="$(cd "${3:-$(dirname "$0")/..}" && pwd)"
OUT_DIR="$PWD"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT
DEST="$WORK_DIR/linuxfabrik-monitoring-plugins"
mkdir "$DEST"

cd "$REPO_DIR"

for tree in check-plugins notification-plugins; do
    for dir in "$tree"/*/; do
        name="$(basename "$dir")"
        [ "$name" = 'example' ] && continue
        [ -f "$dir$name" ] && cp "$dir$name" "$DEST/"
    done
done

# Plugin assets (e.g. the scanrootkit signatures) go flat into assets/, as the
# packages install them; without them scanrootkit ends UNKNOWN. The installer's
# --zip mode reads the sudoers drop-ins, the bash completion and the SELinux
# policy module from the same directory.
mkdir "$DEST/assets"
find check-plugins notification-plugins -mindepth 3 -type f \
    -path '*/assets/*' -not -path '*/example/assets/*' \
    -exec install --mode 0644 {} "$DEST/assets" \;
cp -r assets/bash-completion assets/selinux assets/sudoers "$DEST/assets/"

# The snmp plugin reads its OID lists and MIBs from directories next to itself.
cp -r check-plugins/snmp/device-mibs check-plugins/snmp/device-oids "$DEST/"

cp -r lockfiles "$DEST/"
cp INSTALL.md "$DEST/"

# The linuxfabrik-lib the lockfiles pin (tools/check-lockfiles keeps them all on
# the same version), as source below lib/.
lib_version="$(sed --quiet 's/^linuxfabrik-lib==\([^ ]*\).*/\1/p' lockfiles/py312/requirements.txt)"
[ -n "$lib_version" ] || {
    echo 'No linuxfabrik-lib pin in lockfiles/py312/requirements.txt' >&2
    exit 1
}
curl --fail --location --silent --show-error \
    "https://github.com/Linuxfabrik/lib/archive/refs/tags/v${lib_version}.tar.gz" |
    tar --extract --gzip --directory "$WORK_DIR"
mkdir "$DEST/lib"
cp -p "$WORK_DIR/lib-${lib_version}"/*.py "$WORK_DIR/lib-${lib_version}/LICENSE" "$DEST/lib/"

cd "$WORK_DIR"
zip --quiet --recurse-paths \
    "$OUT_DIR/lfmp-${VERSION}-${ITERATION}.source.noarch.zip" \
    linuxfabrik-monitoring-plugins
echo "$OUT_DIR/lfmp-${VERSION}-${ITERATION}.source.noarch.zip (lib ${lib_version})"
