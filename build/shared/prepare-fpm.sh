#!/usr/bin/env bash

mkdir /build/check-plugins
cd /build/check-plugins

cat > .fpm << EOF
--after-install /repos/monitoring-plugins/build/shared/rpm-post-install
--architecture all
--chdir /tmp/dist/summary/check-plugins
--description "This Enterprise Class Check Plugin Collection offers a bunch of Nagios-compatible check plugins for Icinga, Naemon, Nagios, OP5, Shinken, Sensu and other monitoring applications. Each plugin is a stand-alone command line tool that provides a specific type of check. Typically, your monitoring software will run these check plugins to determine the current status of hosts and services on your network."
--input-type dir
--iteration $PACKET_VERSION
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-monitoring-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Check Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version $RELEASE
EOF

for file in $(cd /tmp/dist/summary/check-plugins; find . -type f | sort); do
    # strip leading './'
    file="${file#./}"
    echo "$file=/usr/lib64/nagios/plugins/$file" >> .fpm
done


mkdir /build/notification-plugins
cd /build/notification-plugins

cat > .fpm << EOF
--architecture all
--chdir /tmp/dist/summary/notification-plugins
--description "Notification scripts for Icinga."
--input-type dir
--iteration $PACKET_VERSION
--license "The Unlicense"
--maintainer "info@linuxfabrik.ch"
--name linuxfabrik-notification-plugins
--rpm-summary "The Linuxfabrik Monitoring Plugins Collection (Notification Plugins)"
--url "https://github.com/Linuxfabrik/monitoring-plugins"
--vendor "Linuxfabrik GmbH, Zurich, Switzerland"
--version $RELEASE
EOF

for file in $(cd /tmp/dist/summary/notification-plugins; find . -type f | sort); do
    # strip leading './'
    file="${file#./}"
    echo "$file=/usr/lib64/nagios/plugins/notifications/$file" >> .fpm
done
