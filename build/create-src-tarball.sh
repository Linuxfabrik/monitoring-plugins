#!/usr/bin/env bash
# 2025051601

set -e -o pipefail -u -x

mkdir --parent $LFMP_DIR_SOURCES

tar --create \
    --directory $LFMP_DIR_REPOS \
    --exclude='monitoring-plugins/.git' \
    --exclude='monitoring-plugins/dist' \
    --exclude='monitoring-plugins/packaged' \
    --file $LFMP_DIR_SOURCES/v$LFMP_VERSION.tar.gz \
    --gzip \
    --verbose --verbose \
    monitoring-plugins
