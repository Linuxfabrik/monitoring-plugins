#!/usr/bin/env bash

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

    mkdir -p /tmp/fpm/check-plugins
    cd /tmp/fpm/check-plugins

    cat > .fpm << EOF
--after-install "$MONITORING_PLUGINS_DIR/build/shared/rpm-post-install"
--architecture all
--chdir /tmp/dist/summary/check-plugins
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

    for file in $(cd /tmp/dist/summary/check-plugins; find . -type f | sort); do
        # strip leading './'
        file="${file#./}"
        echo "$file=/usr/lib64/nagios/plugins/$file" >> .fpm
    done


    mkdir -p /tmp/fpm/notification-plugins
    cd /tmp/fpm/notification-plugins

    cat > .fpm << EOF
--architecture all
--chdir /tmp/dist/summary/notification-plugins
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

    for file in $(cd /tmp/dist/summary/notification-plugins; find . -type f | sort); do
        # strip leading './'
        file="${file#./}"
        echo "$file=/usr/lib64/nagios/plugins/notifications/$file" >> .fpm
    done
}

compile_plugins() {
    MONITORING_PLUGINS_DIR="$1"
    if [[ -z "$MONITORING_PLUGINS_DIR" ]]; then
        echo "Usage: ${FUNCNAME[0]} <MONITORING_PLUGINS_DIR>"
        return 1
    fi

    mkdir -p /tmp/dist/summary/{check,notification}-plugins

    for dir in "$MONITORING_PLUGINS_DIR"/check-plugins/*; do
        check="$(basename "$dir")"
        if [ "$check" != "example" ]; then
            echo -e "\ncompiling $check..."
            pyinstaller_extra_cmdline=''
            if [ -f "$dir/.build_options" ]; then
                echo "Found .build_options, sourcing them"
                . "$dir/.build_options"
            fi
            pyinstaller \
                --clean \
                --distpath /tmp/dist/check-plugins \
                --workpath /tmp/build/check-plugins \
                --specpath /tmp/spec/check-plugins \
                --noconfirm \
                --noupx \
                --onedir \
                $pyinstaller_extra_cmdline \
                "$dir/${check}"
        fi
    done
    \cp -a --no-clobber /tmp/dist/check-plugins/*/* /tmp/dist/summary/check-plugins

    for dir in "$MONITORING_PLUGINS_DIR"/notification-plugins/*; do
        notification="$(basename "$dir")"
        if [ "$notification" != "example" ]; then
            echo -e "\ncompiling $notification..."
            pyinstaller \
                --clean \
                --distpath /tmp/dist/notification-plugins \
                --workpath /tmp/build/notification-plugins \
                --specpath /tmp/spec/notification-plugins \
                --noconfirm \
                --noupx \
                --onedir \
                "$dir/${notification}"
        fi
    done
    \cp -a --no-clobber /tmp/dist/notification-plugins/*/* /tmp/dist/summary/notification-plugins
}
