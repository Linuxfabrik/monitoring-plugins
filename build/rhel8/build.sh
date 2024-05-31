#!/usr/bin/env bash

set -e

PACKAGE_VERSION="$1" # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKAGE_ITERATION="$2" # 2, if there is a bugfix for this package (not for the mp)


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
#gem install fpm

# because fpm install fails on Ruby 2.5.0 due to dotenv, you basically just explicitly
# install the version-pinned dependencies of pleaserun and fpm and then install those without
# any deps (https://github.com/jordansissel/fpm/issues/2048):
gem install dotenv --version 2.8.1 --no-document
gem install clamp --version 1.0.1 --no-document
gem install mustache --version 0.99.8 --no-document
gem install cabin insist stud arr-pm backports rexml --no-document
gem install pleaserun --ignore-dependencies --no-document
gem install fpm --ignore-dependencies --no-document

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
cp -- *.rpm /build/

cd /tmp/fpm/notification-plugins
fpm --output-type rpm
cp -- *.rpm /build/
