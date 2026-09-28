#!/usr/bin/env bash
# 2026092801

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

# Install the data directories the snmp plugin reads next to itself (its OID lists and MIBs,
# see its README), keeping their structure
for dir in device-mibs device-oids; do
    find check-plugins/snmp/$dir -type f -printf '%P\n' | while read -r file; do
        install -D --mode 0644 check-plugins/snmp/$dir/"$file" $LFMP_DIR_TARGET/$dir/"$file"
    done
done
