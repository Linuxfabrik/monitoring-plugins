#!/usr/bin/env bash

set -e

yum -y update
yum -y install git zip
yum -y install binutils

# for compiling selinux policies
yum -y install policycoreutils-devel setools-console yum-utils rpm-build make
yumdownloader --source selinux-policy

yum -y install python39 python39-devel
alias python3=python3.9

yum -y install ruby-devel gcc make rpm-build libffi-devel

# install fpm using gem
gem install fpm

# prepare venv
. /repos/monitoring-plugins/build/shared/venv.sh

# compile using pyinstaller
. /repos/monitoring-plugins/build/shared/compile.sh

# RHEL only - compile .te file to .pp for SELinux
mkdir /build/selinux
cp /repos/monitoring-plugins/selinux/linuxfabrik-monitoring-plugins.te /build/selinux/
cd /build/selinux/
make --file /usr/share/selinux/devel/Makefile linuxfabrik-monitoring-plugins.pp
\cp -a linuxfabrik-monitoring-plugins.pp /tmp/dist/summary/check-plugins

RELEASE=2023051201 # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKET_VERSION=1 # 2, if there is a bugfix for this package (not for the mp)

# prepare files for fpm
. /repos/monitoring-plugins/build/shared/prepare-fpm.sh

# create packages using fpm
cd /build/check-plugins
fpm --output-type rpm

cd /build/notification-plugins
fpm --output-type rpm
