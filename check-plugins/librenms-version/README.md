# Check librenms-version

## Overview

Displays LibreNMS instance information including version, database schema, Python and RRDtool versions via the LibreNMS API. This check does not track new releases since LibreNMS can update itself when running the Git version.

**Data Collection:**

* Queries the LibreNMS API endpoint `/api/v0/system` to retrieve instance metadata
* Reports LibreNMS version, Git branch, database schema, database server version, Net-SNMP, PHP, Python, and RRDtool versions
* Requires a LibreNMS API token with "Global Read" permissions (create one via LibreNMS > Gear Icon > API > API Settings)

**Important Notes:**

* Consider also monitoring the EOL dates for Apache, MariaDB, PHP and other components using the corresponding `*-version` check plugins


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/librenms-version> |
| Nagios/Icinga Check Name              | `check_librenms_version` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | No (`--token` is required) |
| Compiled for Windows                  | No |


## Help

```text
usage: librenms-version [-h] [-V] [--insecure] [--no-proxy]
                        [--timeout TIMEOUT] --token TOKEN [--url URL]

Displays LibreNMS instance information including version, database schema,
Python and RRDtool versions via the LibreNMS API. This check does not track
new releases since LibreNMS can update itself when running the Git version.

options:
  -h, --help         show this help message and exit
  -V, --version      show program's version number and exit
  --insecure         This option explicitly allows insecure SSL connections.
  --no-proxy         Do not use a proxy.
  --timeout TIMEOUT  Network timeout in seconds. Default: 3 (seconds)
  --token TOKEN      LibreNMS API token.
  --url URL          LibreNMS API URL. Default: http://localhost
```


## Usage Examples

```bash
./librenms-version --url http://librenms --token 03xyza61e74a9876f3dc7ab11234229d
```

Output:

```text
LibreNMS 21.6.0 (Git: HEAD), DB-Schema 2021_06_07_123600_create_sessions_table (211), MariaDB 10.6.3-MariaDB, Net-SNMP 5.8, PHP 8.0.8, Python 3.6.8, RRD-Tool 1.7.0
```


## States

* Always returns OK.
* `--always-ok` is not available since the check always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| db-version | Float | Database server version as a floating-point number. |
| librenms-version | Float | LibreNMS version as a floating-point number. |
| netsnmp-version | Float | Net-SNMP version as a floating-point number. |
| php-version | Float | PHP version as a floating-point number. |
| python-version | Float | Python version as a floating-point number. |
| rrdtool-version | Float | RRDtool version as a floating-point number. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
