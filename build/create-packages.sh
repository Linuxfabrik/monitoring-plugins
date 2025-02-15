#!/usr/bin/env bash
# 2025021501

set -e -x

for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do
    for PLUGINS in check-plugins notification-plugins event-plugins; do
        if [[ ! -e $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/$PLUGINS/.fpm ]]; then
            continue;
        fi

        cd $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/$PLUGINS
        case "$LFMP_TARGET_DISTRO" in
        debian11)
            fpm --output-type deb
            fpm --output-type tar
            fpm --output-type zip
            ;;
        debian12)
            fpm --output-type deb
            ;;
        rocky8)
            fpm --output-type rpm
            ;;
        rocky9)
            fpm --output-type rpm
            ;;
        ubuntu2004)
            fpm --output-type deb
            ;;
        ubuntu2204)
            fpm --output-type deb
            ;;
        ubuntu2404)
            fpm --output-type deb
            ;;
        *)
            continue
            ;;
        esac

    done
done