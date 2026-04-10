# Check ipmi-sel

## Overview

Checks the IPMI System Event Log (SEL) for entries and alerts when events are found. Entries can be filtered by regex using `--ignore`. To clear the SEL after resolving issues, run `ipmitool sel clear`. Requires root or sudo.

**Data Collection:**

* Executes `ipmitool sel elist` locally or against a remote BMC/iLO via IPMI over LAN
* For remote access, supports both IPMI v1.5 (`--interface=lan`) and IPMI v2.0 (`--interface=lanplus`)
* Output lines are displayed in reverse chronological order with pipe characters replaced by semicolons

**Compatibility:**

* Cross-platform


**