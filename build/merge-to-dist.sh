#!/usr/bin/env bash
# 2025021601

set -e -x

# We are on the Ubuntu VM (not in the container).
for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do
    for PLUGINS in check-plugins notification-plugins event-plugins; do
        if [[ -d $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS && -n "$(ls --almost-all $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS)" ]]; then
            # Directory exists and is not empty.
            mkdir -p $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS
            # Note that we use the special /.' suffix to copy **only the contents** of each *.dist directory (preserving attributes).
            # Unfortunately,mv does not have a built‐in equivalent to "move the contents of a directory" using the/.' trick.
            # Therefore we copy and remove later to save disk space, important in github runners.
            echo "cp --archive $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.dist/. $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/"
            \cp --archive --verbose $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.dist/. $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/
            if compgen -G "LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.pp" > /dev/null; then
                # handle compiled SELinux policies
                mkdir -p $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/assets
                echo "\cp --archive $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.pp $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/assets"
                \cp --archive --verbose $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS/*.pp $LFMP_DIR_DIST/$LFMP_TARGET_DISTRO/$PLUGINS/assets
            fi
            rm -rf $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/$PLUGINS
        fi
    done
done
