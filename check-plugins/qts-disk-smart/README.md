# Check qts-disk-smart


## Overview

Checks disk SMART values on QNAP appliances running QTS via the API. Reports drive health, temperature, and SMART attribute status for all installed HDDs and SSDs. Disk temperature thresholds are determined automatically from the QTS system configuration.

**Important Notes:**

* 3rd party Python module `xmltodict` required
* Tested on [QuTScloud](https://www.qnap.com/en-us/download?model=qutscloud&category=firmware) v4.5.6+
* The user used for monitoring must be a member of the "administrators" group. It is not sufficient to be a member of the "everyone" group.

**Data Collection:**

* Authenticates against the QTS API and fetches disk SMART data via `/cgi-bin/disk/qsmart.cgi`
* Fetches system information via `/cgi-bin/management/manaRequest.cgi` to retrieve temperature thresholds
* This check does not run SMART itself. To get the latest values, schedule the built-in SMART check in the QTS web interface.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/qts-disk-smart> |
| Nagios/Icinga Check Name              | `check_qts_disk_smart` |
| Check Interval Recommendation         | Every 8 hours |
| Can be called without parameters      | No (`--password` and `--url` are required) |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `xmltodict` |


## Help

```text
usage: qts-disk-smart [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      --password PASSWORD [--timeout TIMEOUT] --url URL
                      [--username USERNAME]

Checks disk SMART values on QNAP appliances running QTS via the API. Reports
drive health, temperature, and SMART attribute status. Alerts when any disk
reports a non-normal SMART status.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  QTS API password.
  --timeout TIMEOUT    Network timeout in seconds. Default: 6 (seconds)
  --url URL            QTS-based appliance URL. Example:
                       `--url=https://192.168.1.1:8080`.
  --username USERNAME  QTS API username. Default: admin
```


## Usage Examples

```bash
./qts-disk-smart --url http://qts:8080 --username admin --password linuxfabrik --insecure
```

Output:

```text
Checked 12 disks. All are healthy.

* Disk 1 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 46°C)
* Disk 2 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 48°C)
* Disk 3 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 47°C)
* Disk 4 (ST16000NE000-2RW103, SerNo 382jdh237, Temp 44°C)
* Disk 5 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 43°C)
* Disk 6 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 43°C)
* Disk 7 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 42°C)
* Disk 8 (ST12000VN0007-2GS116, SerNo 382jdh237, Temp 40°C)
* PCIe 2 M.2 SSD 1 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 48°C)
* PCIe 2 M.2 SSD 2 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 49°C)
* PCIe 4 M.2 SSD 1 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 47°C)
* PCIe 4 M.2 SSD 2 (FireCuda 520 SSD ZP2000GM30002, SerNo 382jdh237, Temp 48°C)
```


## States

* OK if all disks are healthy and temperatures are below the thresholds.
* WARN if any disk reports a non-normal SMART health status or temperature exceeds the warning threshold.
* CRIT if any disk temperature exceeds the critical threshold.
* UNKNOWN if no disks are found.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| NAME\_\<model\>\_\<serno\>\_temperature | Number | Temperature in degrees Celsius. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
