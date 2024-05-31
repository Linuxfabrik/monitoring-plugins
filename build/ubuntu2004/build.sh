#!/usr/bin/env bash

set -e

PACKAGE_VERSION="$1" # version number has to start with a digit, for example 2023123101; "main" for the latest development version
PACKAGE_ITERATION="$2" # 2, if there is a bugfix for this package (not for the mp)


apt-get -y update
apt-get -y install git
apt-get -y install python3-venv python3-pip

# dependencies for gem / fpm
apt-get install -y ruby ruby-dev rubygems build-essential

# install fpm using gem
#gem install fpm

# because fpm install fails on Ruby 2.7.0 due to dotenv, you basically just explicitly
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

# prepare files for fpm
. /repos/monitoring-plugins/build/shared/prepare-fpm.sh

# create packages using fpm
cd /tmp/fpm/check-plugins
fpm --output-type deb
cp -- *.deb /build/

cd /tmp/fpm/notification-plugins
fpm --output-type deb
cp -- *.deb /build/
