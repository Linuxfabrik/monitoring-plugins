#!/usr/bin/env bash
# 2025051901

set -e -o pipefail -u -x

# Discover and install plugins
find check-plugins event-plugins notification-plugins \
    -maxdepth 2 \
    -type f \
    -not -name example \
    -regextype posix-extended \
    -regex '.*/([^/]+)/\1$' \
    -exec install {} $LFMP_DIR_TARGET \;

# Discover and install plugin assets
install --directory $LFMP_DIR_TARGET/assets
find check-plugins event-plugins notification-plugins \
    -mindepth 3 \
    -type f \
    -path '*/assets/*' \
    -not -path '*/example/assets/*' \
    -exec install --mode 0644 {} $LFMP_DIR_TARGET/assets \;
