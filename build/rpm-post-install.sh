#!/usr/bin/env bash
# 2025021101

if ! command -v getenforce &> /dev/null; then
    exit 0
fi
SELINUXSTATUS=$(getenforce)
if [ "$SELINUXSTATUS" != "Enforcing" ]; then
    exit 0
fi
restorecon -r /usr/lib64/nagios
setsebool -P nagios_run_sudo on
semodule --install /usr/lib64/nagios/plugins/assets/linuxfabrik-monitoring-plugins.pp
