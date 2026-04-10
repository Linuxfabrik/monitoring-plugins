# Check redfish-drives

## Overview

Checks the state of all physical drives and storage media in a Redfish-compatible server via the Redfish API. Iterates over the Systems collection, fetches storage controllers and their attached drives, and reports health status, media type, protocol, capacity, and predicted media life left.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, queries the Storage collection and iterates over all storage controllers and attached drives
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates drives and controllers in "Enabled" or "Quiesced" state

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Compatibility:**

* Linux only


## 