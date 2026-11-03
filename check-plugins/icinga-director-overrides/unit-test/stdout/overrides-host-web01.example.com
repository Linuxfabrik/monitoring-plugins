{
    "object_name": "web01.example.com",
    "object_type": "object",
    "services": [
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
