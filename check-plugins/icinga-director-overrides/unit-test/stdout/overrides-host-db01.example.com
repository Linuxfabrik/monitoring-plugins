{
    "object_name": "db01.example.com",
    "object_type": "object",
    "services": [
        {
            "check_command": "cmd-check-apache-httpd-security-sudo",
            "imports": [],
            "object_name": "Apache httpd Security",
            "object_type": "object",
            "service_set": "Apache httpd Service Set",
            "vars": {
                "apache_httpd_security_ignore": [
                    "Proxy modules",
                    "Status module"
                ],
                "criticality": "C"
            }
        },
        {
            "check_command": "cmd-check-cpu-usage",
            "imports": [],
            "object_name": "CPU Usage",
            "object_type": "object",
            "service_set": "OS - RHEL Basic Service Set",
            "vars": {
                "cpu_usage_critical": 95,
                "cpu_usage_warning": 80,
                "criticality": "C"
            }
        },
        {
            "check_command": "cmd-check-disk-usage",
            "imports": [],
            "object_name": "Disk Usage",
            "object_type": "object",
            "service_set": "OS - RHEL Basic Service Set",
            "vars": {
                "disk_usage_ignore": [
                    "/tmp",
                    "/boot"
                ],
                "criticality": "C"
            }
        },
        {
            "check_command": "cmd-check-nextcloud-stats",
            "imports": [],
            "object_name": "Nextcloud Stats",
            "object_type": "object",
            "service_set": "Nextcloud Service Set",
            "vars": {
                "criticality": "C",
                "nextcloud_stats_hostname": "localhost",
                "nextcloud_stats_login": "admin",
                "nextcloud_stats_url": "https://$nextcloud_stats_hostname$/ocs/v2.php/apps/serverinfo/api/v1/info"
            }
        },
        {
            "check_command": "cmd-check-snmp-uptime",
            "imports": [],
            "object_name": "SNMP Uptime",
            "object_type": "object",
            "service_set": null,
            "vars": {
                "criticality": "C"
            }
        },
        {
            "check_command": "cmd-check-swap-usage",
            "imports": [],
            "object_name": "Swap Usage",
            "object_type": "object",
            "service_set": "OS - RHEL Basic Service Set",
            "vars": {
                "criticality": "C",
                "swap_usage_critical": 90,
                "swap_usage_warning": 50
            }
        }
    ]
}
