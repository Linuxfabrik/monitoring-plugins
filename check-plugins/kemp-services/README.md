# Check kemp-services

## Overview

Monitors virtual services on a KEMP LoadMaster appliance via its REST API and alerts when any virtual service or its real servers are in a non-operational state.

**Data Collection:**

* Queries the KEMP LoadMaster REST API endpoint `/access/listvs` using Basic authentication
* Parses the XML response to extract the NickName and Status of each virtual service
* Use `--filter` to only check virtual services whose NickName contains a specific string

**Compatibility:**

* Cross-platform

**Important Notes:**

* Any KEMP LoadMaster appliance with REST API enabled


## 