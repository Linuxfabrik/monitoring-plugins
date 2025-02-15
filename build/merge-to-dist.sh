#!/usr/bin/env bash
# 2025021501

set -e -x

# We are on the Ubuntu VM (not in the container).
for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do
    for PLUGINS in check-plugins notification-plugins event-plugins; do
        if [[ -d $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS && -n "$(ls --almost-all $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS)" ]]; then
            mkdir -p $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS
            # directory exists and is not empty
            echo "cp --archive $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.dist/. $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/"
            \cp --archive $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.dist/. $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/
        fi
    done
done
