{
    "object_name": "web01.example.com",
    "object_type": "object",
    "services": [
        {
            "check_command": "cmd-check-swap-usage",
            "object_name": "Swap Usage",
            "service_set": "Linux Set",
            "vars": {
                "criticality": "C",
                "swap_usage_critical": 90,
                "swap_usage_warning": 50
            }
        }
    ]
}
