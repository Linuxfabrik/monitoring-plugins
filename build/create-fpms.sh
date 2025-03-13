#!/usr/bin/env bash
# 2025021701

set -e -x

get_vendor() {
    local vendor

    # Check if /etc/os-release exists
    if [[ -f /etc/os-release ]]; then
        vendor=$(source /etc/os-release && echo "$ID")
    fi

    # Map the vendor to standardized names
    case "$vendor" in
    rhel|centos|fedora|rocky|almalinux|suse|opensuse)
        vendor="RedHat"
        ;;
    debian|ubuntu|mint)
        vendor="Debian"
        ;;
    *)
        vendor="other"
        ;;
    esac
    echo "$vendor"
}


for LFMP_TARGET_DISTRO in $LFMP_TARGET_DISTROS; do

    # check-plugins
    if [[ ! -d $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/check-plugins ]]; then
        continue
    fi

    mkdir -p $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins
    cat > $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins/.fpm << EOF
--after-install $LFMP_DIR_REPOS/monitoring-plugins/build/rpm-post-install.sh
--architecture $LFMP_ARCH
--chdir $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO
--description "This Enterprise Class Check Plugin Collection offers a bunch of Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network."
--input-type dir
--iteration $LFMP_PACKAGE_ITERATION
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-monitoring-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Check Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version $LFMP_VERSION
EOF

    LFMP_TARGET_DISTRO_FAMILY=$(get_vendor $LFMP_TARGET_DISTRO)

    # prepare and ship the sudoers file
    mkdir -p $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/assets/
    if [ "$LFMP_TARGET_DISTRO_FAMILY" != "other" ]; then
        \cp --archive "$LFMP_DIR_REPOS/monitoring-plugins"/assets/sudoers/"$LFMP_TARGET_DISTRO_FAMILY".sudoers $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/assets/sudoers
        echo "assets/sudoers=/etc/sudoers.d/monitoring-plugins" >> $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins/.fpm
    fi

    # prepare and ship the asset files for all check-plugins
    mkdir -p $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/check-plugins/assets/

    # Find all assets - but avoiding `find` as we get `/bin/sh: find: command not found` in Github runners sometimes

    # Enable recursive globbing and allow unmatched globs to expand to nothing.
    shopt -s globstar nullglob
    # Loop over all directories named "assets" within check-plugins (at any depth).
    for asset_dir in "$LFMP_DIR_REPOS/monitoring-plugins/check-plugins"/**/assets; do
        # Ensure it's really a directory.
        [ -d "$asset_dir" ] || continue

        # Recursively loop through all files within the assets directory.
        for file in "$asset_dir"/**/*; do
            # Only process regular files.
            [ -f "$file" ] || continue
            # Copy each file to the target directory.
            cp --archive "$file" "$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/check-plugins/assets/"
        done
    done

    # Build the check-plugins file list - again avoiding `find`...
    shopt -s globstar nullglob
    for file in "$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/check-plugins"/**/*; do
        # Only process regular files.
        [ -f "$file" ] || continue
        # Escape spaces in the file name.
        escaped_file="${file// /\\ }"
        echo "check-plugins/$escaped_file=/usr/lib64/nagios/plugins/$escaped_file" >> "$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins/.fpm"
    done

    # fix directories
    sed --in-place "s#$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/check-plugins/##g" $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins/.fpm
    echo $(cat "$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/check-plugins/.fpm")

    # ---

    # notification plugins
    if [[ ! -d $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/notification-plugins ]]; then
        continue
    fi

    mkdir -p $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/notification-plugins
    cat > $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/notification-plugins/.fpm << EOF
--architecture $LFMP_ARCH
--chdir $LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO
--description "Additional notification scripts for Icinga from the Linuxfabrik Monitoring Plugins project."
--input-type dir
--iteration $LFMP_PACKAGE_ITERATION
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-notification-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Notification Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version $LFMP_VERSION
EOF

    # build the notification-plugins file list
    shopt -s globstar nullglob

    for file in "$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/notification-plugins"/**/*; do
        # Only process regular files.
        [ -f "$file" ] || continue
        # Escape spaces in the file name.
        escaped_file="${file// /\\ }"
        echo "notification-plugins/$escaped_file=/usr/lib64/nagios/plugins/notifications/$escaped_file" >> "$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/notification-plugins/.fpm"
    done

    # fix directories
    sed --in-place "s#$LFMP_DIR_COMPILED/$LFMP_TARGET_DISTRO/notification-plugins/##g" $LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/notification-plugins/.fpm
    echo $(cat "$LFMP_DIR_PACKAGED/$LFMP_TARGET_DISTRO/notification-plugins/.fpm")

done
