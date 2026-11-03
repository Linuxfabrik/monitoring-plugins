{
    "object_name": "web01.example.com",
    "object_type": "object",
    "services": [
        {
            "check_command": "cmd-check-many",
            "imports": [],
            "object_name": "Many",
            "object_type": "object",
            "service_set": "Many Set",
            "vars": {
                "many_v01": "1",
                "many_v02": "1",
                "many_v03": "1",
                "many_v04": "1",
                "many_v05": "1",
                "many_v06": "1",
                "many_v07": "1",
                "many_v08": "1",
                "many_v09": "1",
                "many_v10": "1",
                "many_v11": "1",
                "many_v12": "1",
                "many_v13": "1",
                "many_v14": "1",
                "many_v15": "1",
                "many_v16": "1",
                "many_v17": "1",
                "many_v18": "1",
                "many_v19": "1",
                "many_v20": "1",
                "many_v21": "1",
                "many_v22": "1",
                "many_v23": "1",
                "many_v24": "1",
                "many_v25": "1",
                "many_v26": "1",
                "many_v27": "1",
                "many_v28": "1",
                "many_v29": "1",
                "many_v30": "1"
            }
        }
    ]
}
