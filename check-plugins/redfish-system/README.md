# Check redfish-system

## Overview

Checks the overall system health reported by a Redfish-compatible server via the Redfish API. Iterates over the Systems collection and reports each member's identification (manufacturer, model, hostname, SKU, serial number), its compute summary (processors, BIOS version, power state, indicator LED) and its rolled-up health status.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.
* This check reports system-level health only. For drive and storage-controller monitoring use `redfish-drives`.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member in "Enabled" or "Quiesced" state, reads the `Status` block (including `HealthRollup`) and the compute summary
* Uses HTTP Basic authentication if `--username` and `--password` are provided


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-system> |
| Nagios/Icinga Check Name              | `check_redfish_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-system [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--test TEST] [--timeout TIMEOUT]
                      [--url URL] [--username USERNAME]

Checks the overall system health reported by a Redfish-compatible server via
the Redfish API. Reports every enabled system member with its identification
(manufacturer, model, hostname, SKU, serial number), compute summary
(processors, BIOS version, power state, indicator LED) and rolled-up health
status, and alerts whenever any system's status leaves `OK`. Use `redfish-
drives` for drive- and storage-controller-specific monitoring.

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
./redfish-system --url https://bmc --username redfish-monitoring --password 'linuxfabrik'
```

Output:

```text
Checked system health on 1 member. There are warnings.

Member: Dell Inc. PowerEdge R750, HostName: web483, Processors: 2x Intel(R) Xeon(R) Gold 6354 CPU @ 3.00GHz (72 logical), BIOS: 1.1.3, Power: On, LED: Lit, SKU: ABCDEFG, SerNo: 1234567890ABCDE [WARNING]
```


## States

* OK if every enabled system member reports `Status.Health` (or `Status.HealthRollup`) as "OK".
* WARN if any enabled system member reports `Status.Health` (or `Status.HealthRollup`) as "Warning".
* CRIT if any enabled system member reports `Status.Health` (or `Status.HealthRollup`) as "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

There is no perfdata.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
