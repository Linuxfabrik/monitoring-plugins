#!/usr/bin/env bash

set -e

RELEASE="$1" # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKET_VERSION="$2" # 2, if there is a bugfix for this package (not for the mp)


apt-get -y update
apt-get -y install git
apt-get -y install python3-venv python3-pip

# dependencies for gem / fpm
apt-get install -y ruby ruby-dev rubygems build-essential

# install fpm using gem
gem install fpm

# prepare venv
. /repos/monitoring-plugins/build/shared/venv.sh

# compile using pyinstaller
. /repos/monitoring-plugins/build/shared/compile.sh

# prepare files for fpm
. /repos/monitoring-plugins/build/shared/prepare-fpm.sh

# create packages using fpm
cd /tmp/fpm/check-plugins
fpm --output-type deb
cp *.deb /build/

cd /tmp/fpm/notification-plugins
fpm --output-type deb
cp *.deb /build/
