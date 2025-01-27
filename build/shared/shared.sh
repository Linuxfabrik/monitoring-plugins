#!/usr/bin/env bash

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

compile_plugins() {
    MONITORING_PLUGINS_DIR="$1"
    if [[ -z "$MONITORING_PLUGINS_DIR" ]]; then
        echo "Usage: ${FUNCNAME[0]} <MONITORING_PLUGINS_DIR> [<CHECK_PLUGIN>]"
        return 1
    fi
    CHECK_PLUGIN="$2"
    if [[ -z "$CHECK_PLUGIN" ]]; then
        CHECK_PLUGIN='*'
    fi

    mkdir -p /tmp/output/summary/{check,notification}-plugins

    for dir in "$MONITORING_PLUGINS_DIR"/check-plugins/$CHECK_PLUGIN; do
        check="$(basename "$dir")"
        if [ "$check" != "example" ]; then
            echo -e "\ncompiling $check..."
            nuitka \
                --assume-yes-for-downloads \
                --output-dir=/tmp/output/check-plugins/ \
                --remove-output \
                --standalone \
                "$dir/$check"
            # remove ".bin" suffix
            mv "/tmp/output/check-plugins/$check.dist/$check.bin" "/tmp/output/check-plugins/$check.dist/$check"
        fi
    done
    \cp --archive --no-clobber /tmp/output/check-plugins/*.dist/* /tmp/output/summary/check-plugins

    if [ "$CHECK_PLUGIN" == "*" ]; then
        # only build notification plugins if all check plugins should be built
        for dir in "$MONITORING_PLUGINS_DIR"/notification-plugins/*; do
            notification="$(basename "$dir")"
            if [ "$notification" != "example" ]; then
                echo -e "\ncompiling $notification..."
                nuitka \
                    --assume-yes-for-downloads \
                    --output-dir=/tmp/output/notification-plugins/ \
                    --remove-output \
                    --standalone \
                    "$dir/$notification"
                # remove ".bin" suffix
                mv "/tmp/output/notification-plugins/$notification.dist/$notification.bin" "/tmp/output/notification-plugins/$notification.dist/$notification"
            fi
        done
        \cp --archive --no-clobber /tmp/output/notification-plugins/*.dist/* /tmp/output/summary/notification-plugins
    fi

}

prepare_fpm() {
    PACKAGE_VERSION="$1"
    PACKAGE_ITERATION="$2"
    MONITORING_PLUGINS_DIR="$3"

    if [[ -z "$PACKAGE_VERSION" || -z "$PACKAGE_ITERATION" || -z "$MONITORING_PLUGINS_DIR" ]]; then
        echo "Usage: ${FUNCNAME[0]} <PACKAGE_VERSION> <PACKAGE_ITERATION> <MONITORING_PLUGINS_DIR>"
        echo "  PACKAGE_VERSION: Version number starting with a digit (e.g. 2023123101) or 'main' for the latest development version."
        echo "  PACKAGE_ITERATION: Iteration number (e.g. 2) to specify the bugfix level for this package."
        echo "  MONITORING_PLUGINS_DIR: Path to the monitoring-plugins directory."
        exit 1
    fi

    if [[ "$PACKAGE_VERSION" == "main" ]]; then
      # Replace PACKAGE_VERSION with the current day in format YYYYMMDD01 (Debian packages don't like "main")
      PACKAGE_VERSION=$(date +"%Y%m%d01")
    fi

    mkdir -p /tmp/fpm/check-plugins
    cd /tmp/fpm/check-plugins || exit 1

    cat > .fpm << EOF
--after-install "$MONITORING_PLUGINS_DIR/build/shared/rpm-post-install"
--architecture all
--chdir /tmp/output/summary/check-plugins
--description "This Enterprise Class Check Plugin Collection offers a bunch of Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network."
--input-type dir
--iteration "$PACKAGE_ITERATION"
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-monitoring-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Check Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version "$PACKAGE_VERSION"
EOF

    for file in $(cd /tmp/output/summary/check-plugins || exit 1; find . -type f | sort); do
        file=${file#./}      # Remove leading './'
        file=${file// /\\ }  # Escape all spaces
        echo "$file=/usr/lib64/nagios/plugins/$file" >> .fpm
    done

    # prepare and ship the sudoers file
    vendor=$(get_vendor)
    if [ "$vendor" != "other" ]; then
        \cp --archive "$MONITORING_PLUGINS_DIR"/assets/sudoers/"$vendor".sudoers /tmp/output/summary/check-plugins/_sudoers
    else
        true > /tmp/output/summary/check-plugins/_sudoers
    fi
    echo "_sudoers=/etc/sudoers.d/monitoring-plugins" >> .fpm


    mkdir -p /tmp/fpm/notification-plugins
    cd /tmp/fpm/notification-plugins || exit 1

    cat > .fpm << EOF
--architecture all
--chdir /tmp/output/summary/notification-plugins
--description "Notification scripts for Icinga."
--input-type dir
--iteration "$PACKAGE_ITERATION"
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-notification-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Notification Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version "$PACKAGE_VERSION"
EOF

    for file in $(cd /tmp/output/summary/notification-plugins || exit 1; find . -type f | sort); do
        file=${file#./}      # Remove leading './'
        file=${file// /\\ }  # Escape all spaces
        echo "$file=/usr/lib64/nagios/plugins/notifications/$file" >> .fpm
    done

}
