#!/usr/bin/env bash

set -e

RELEASE="$1" # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKET_VERSION="$2" # 2, if there is a bugfix for this package (not for the mp)


yum -y update
yum -y install git zip
yum -y install binutils

# for compiling selinux policies
yum -y install make selinux-policy-devel

yum -y install python39 python39-devel
alias python3=python3.9

# dependencies for gem / fpm
yum -y install ruby-devel gcc make rpm-build libffi-devel

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

cd /tmp/fpm/notification-plugins
fpm --output-type rpm
cp *.rpm /build/
