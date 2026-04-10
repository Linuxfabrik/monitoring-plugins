# Check redfish-sel

## Overview

Checks the System Event Log (SEL) of Redfish-compatible servers via the Redfish API. Returns an alert based on the severity of the log entries. Supports multiple vendors with vendor-specific SEL paths.

**Alerting Logic:**

* WARN if any SEL entry has severity "Warning"
* CRIT if any SEL entry has severity "Critical"
* `--always-ok` suppresses all alerts and always returns OK

**Data Collection:**

* Queries `/redfish/v1/` to detect the vendor (AMI, Avigilon, Cisco, Dell, HPE, Lenovo, Supermicro, TS Fujitsu, or generic)
* Uses the appropriate entry point (`Managers` or `Systems` depending on vendor) and vendor-specific LogServices SEL path
* Uses HTTP Basic authentication if `--username` and `--password` are provided

**Important Notes:**

* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Compatibility:**

* Tested on DELL iDRAC and DMTF Simulator
* Vendor support: AMI, Avigilon, Cisco, Dell, HPE/HP, Lenovo, Supermicro, TS Fujitsu, and generic Redfish implementations
* Linux only


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-sel> |
| Nagios/Icinga Check Name              | `check_redfish_sel` |
| Check Interval Recommendation         | Every 15 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-sel [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                   [--password PASSWORD] [--test TEST] [--timeout TIMEOUT]
                   [--url URL] [--username USERNAME]

Checks the System Event Log (SEL) of Redfish-compatible servers via the
Redfish API. Alerts based on the severity of log entries. Entries can be
filtered by regex.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Redfish API password.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Redfish API URL. Default: https://localhost:5000
  --username USERNAME  Redfish API username.
```


## Usage Examples

```bash
./redfish-sel --url https://bmc --username redfish-monitoring --password 'mypassword'
```

Output:

```text
Checked SEL on 1 member. There are critical errors.

Member: /redfish/v1/Managers/iDRAC.Embedded.1
* 2021-10-14T10:32:20+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]
* 2021-10-14T09:52:27+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]
* 2021-10-14T02:02:47+02:00: The system inlet temperature is greater than the upper critical threshold. [CRITICAL]
* 2021-10-14T00:10:12+02:00: The system inlet temperature is greater than the upper warning threshold. [WARNING]
```


## States

* OK if no SEL entries with severity "Warning" or "Critical" are found.
* WARN if any SEL entry has severity "Warning".
* CRIT if any SEL entry has severity "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
