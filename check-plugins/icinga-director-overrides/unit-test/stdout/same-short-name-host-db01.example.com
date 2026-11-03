{
    "object_name": "db01.example.com",
    "object_type": "object",
    "services": [
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
        }
    ]
}
