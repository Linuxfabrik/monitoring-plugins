# Check redfish-sel

## Overview

Checks the System Event Log (SEL) of Redfish-compatible servers via the Redfish API. Returns an alert based on the severity of the log entries. Supports multiple vendors with vendor-specific SEL paths.

**Data Collection:**

* Queries `/redfish/v1/` to detect the vendor (AMI, Avigilon, Cisco, Dell, HPE, Lenovo, Supermicro, TS Fujitsu, or generic)
* Uses the appropriate entry point (`Managers` or `Systems` depending on vendor) and vendor-specific LogServices SEL path
* Uses HTTP Basic authentication if `--username` and `--password` are provided

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* Vendor support: AMI, Avigilon, Cisco, Dell, HPE/HP, Lenovo, Supermicro, TS Fujitsu, and generic Redfish implementations
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Compatibility:**

* Linux only


## 