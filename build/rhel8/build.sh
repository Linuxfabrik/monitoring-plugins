#!/usr/bin/env bash

set -e

PACKAGE_VERSION="$1"
PACKAGE_ITERATION="$2"

if [[ -z "$PACKAGE_VERSION" || -z "$PACKAGE_ITERATION" ]]; then
    echo "Usage: $(basename "$0") <PACKAGE_VERSION> <PACKAGE_ITERATION>"
    echo "  PACKAGE_VERSION: Version number starting with a digit (e.g. 2023123101) or 'main' for the latest development version."
    echo "  PACKAGE_ITERATION: Iteration number (e.g. 2) to specify the bugfix level for this package."
    exit 1
fi

CURRENT_DIR="$(dirname "$(realpath "$BASH_SOURCE")")"
BUILD_SHARED_DIR="$CURRENT_DIR/../shared"
LIB_DIR="$CURRENT_DIR/../../lib"
MONITORING_PLUGINS_DIR="$CURRENT_DIR/../../"

if [[ ! -d "$LIB_DIR" ]]; then
    echo "The Python libraries (https://github.com/Linuxfabrik/lib) could not be found at $LIB_DIR."
    echo "They should be in a directory called 'lib' on the same level as the monitoring-plugins directory."
    exit 2
fi

# include shared functions
. "$BUILD_SHARED_DIR/shared.sh"

source /opt/venv/bin/activate
python3 --version
python3 -m pip install --requirement="$MONITORING_PLUGINS_DIR/requirements.txt"

# compile using pyinstaller
compile_plugins "$MONITORING_PLUGINS_DIR"

# RHEL only - compile .te file to .pp for SELinux
mkdir /tmp/selinux
cp /repos/monitoring-plugins/selinux/linuxfabrik-monitoring-plugins.te /tmp/selinux/
cd /tmp/selinux/
make --file /usr/share/selinux/devel/Makefile linuxfabrik-monitoring-plugins.pp
\cp -a linuxfabrik-monitoring-plugins.pp /tmp/dist/summary/check-plugins

# prepare files for fpm
prepare_fpm "$PACKAGE_VERSION" "$PACKAGE_ITERATION" "$MONITORING_PLUGINS_DIR"

# create packages using fpm
cd /tmp/fpm/check-plugins
fpm --output-type rpm
cp -- *.rpm /build/
# build tar & zip
fpm --output-type tar
cp -- *.tar /build/
fpm --output-type zip
cp -- *.zip /build/

cd /tmp/fpm/notification-plugins
fpm --output-type rpm
cp -- *.rpm /build/
# build tar & zip
fpm --output-type tar
cp -- *.tar /build/
fpm --output-type zip
cp -- *.zip /build/
