#!/usr/bin/env bash

set -e

RELEASE="$1" # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKET_VERSION="$2" # 2, if there is a bugfix for this package (not for the mp)


# subscription-manager repos --enable rhel-7-server-optional-rpms --enable rhel-server-rhscl-7-rpms # not needed in ubi containers

yum -y update
yum -y install git
yum -y install binutils

# for compiling selinux policies
yum -y install make selinux-policy-devel

# use latest python available from scl
yum -y install rh-python38 rh-python38-python-devel
source /opt/rh/rh-python38/enable # analogous to `scl enable rh-python38 bash`

# dependencies for gem / fpm
# use latest ruby available from scl
yum -y install gcc redhat-rpm-config rpm-build squashfs-tools
yum -y install rh-ruby30 rh-ruby30-ruby-devel
source /opt/rh/rh-ruby30/enable # analogous to `scl enable rh-ruby30 bash`

# install fpm using gem
gem install fpm

# prepare venv
. /repos/monitoring-plugins/build/shared/venv.sh

# compile using pyinstaller
. /repos/monitoring-plugins/build/shared/compile.sh

# RHEL only - compile .te file to .pp for SELinux
mkdir /tmp/selinux
cp /repos/monitoring-plugins/selinux/linuxfabrik-monitoring-plugins.te /tmp/selinux/
cd /tmp/selinux/
make --file /usr/share/selinux/devel/Makefile linuxfabrik-monitoring-plugins.pp
\cp -a linuxfabrik-monitoring-plugins.pp /tmp/dist/summary/check-plugins

# prepare files for fpm
. /repos/monitoring-plugins/build/shared/prepare-fpm.sh

# create packages using fpm
cd /tmp/fpm/check-plugins
fpm --output-type rpm
cp *.rpm /build/
fpm --output-type tar
cp *.tar /build/
fpm --output-type zip
cp *.zip /build/

cd /tmp/fpm/notification-plugins
fpm --output-type rpm
cp *.rpm /build/
fpm --output-type tar
cp *.tar /build/
fpm --output-type zip
cp *.zip /build/
