# Check deb-updates

## Overview

Checks for available APT package updates on Debian, Ubuntu, and compatible systems. Reports the number of pending updates and upgrades, and alerts when updates are available. This check only lists updates and never actually installs anything. Requires root or sudo.

**Data Collection:**

* Runs `sudo apt-get update --quiet 2` to refresh the package cache
* Runs `apt list --upgradable` to determine available updates
* Stores the results in a local SQLite database for flexible querying via `--query`
* Optionally filters for security-critical updates only (`--only-critical`), matching packages from `*-security` repositories

**Compatibility:**

* Linux

**Important Notes:**

* Debian 11+, Ubuntu 20+, and other apt-based distributions
* The plugin stores all relevant information in a local SQLite database. For the `--query` parameter, the following database column is available: `package` (TEXT)
* As the output interface of the `apt` tool is not stable, the database table has been kept deliberately simple and consists of only one column
* The user running this plugin must have sudo permissions with NOPASSWD for `apt-get update`

Example content of the `package` column:

```text
base-files/stable 12.4+deb12u11 amd64 [upgradable from: 12.4+deb12u5]
bash/stable 5.2.15-2+b8 amd64 [upgradable from: 5.2.15-2+b2]
bind9-dnsutils/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
```


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/deb-updates> |
| Nagios/Icinga Check Name              | `check_deb_updates` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses State File                       | `$TEMP/linuxfabrik-monitoring-plugins-deb-updates.db` |


## Help

```text
usage: deb-updates [-h] [-V] [--always-ok] [--only-critical] [--query QUERY]
                   [--timeout TIMEOUT] [-w WARN]

Checks for available APT package updates on Debian, Ubuntu, and compatible
systems. Reports the number of pending updates and upgrades, and alerts when
updates are available. This check only lists updates and never actually
installs anything. Requires root or sudo.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --always-ok         Always returns OK.
  --only-critical     Only report security-critical updates and upgrades.
  --query QUERY       SQL WHERE clause to narrow down results from the
                      internal updates table. Supports regular expressions via
                      a REGEXP statement. If specified, a list of matching
                      updates is printed. Have a look at the README for a list
                      of available columns. Example: `--query='package like
                      "bind9-%"'`. Default: 1
  --timeout TIMEOUT   Network timeout in seconds. Default: 60 (seconds)
  -w, --warning WARN  Minimum number of pending packages to trigger a WARNING.
                      Default: 1
```


## Usage Examples

```bash
./deb-updates --only-critical --query='package like "bind9-%"'
```

Output:

```text
3 critical updates available [WARNING]:
* bind9-dnsutils/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
* bind9-host/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
* bind9-libs/stable,stable-security 1:9.18.33-1~deb12u2 amd64 [upgradable from: 1:9.18.19-1~deb12u1]
```


## States

* OK if no updates are available (or the count is below `--warning`).
* WARN if the number of updatable packages is >= `--warning` (default: 1).
* UNKNOWN if `apt-get update` or `apt list --upgradable` fails.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| updates | Number | Number of updatable packages matching the current `--query`. |


## Troubleshooting

`apt-get update returned with an error.`  
The plugin runs `sudo apt-get update` and requires a working sudoers configuration. The package installs `/etc/sudoers.d/linuxfabrik-monitoring-plugins` automatically. If this file is missing, restore it:

```bash
apt install --reinstall -o Dpkg::Options::="--force-confmiss" linuxfabrik-monitoring-plugins
```

If the file exists but the error persists, verify that the monitoring user (typically `icinga` or `nagios`) can run `sudo apt-get update` without a password prompt:

```bash
su icinga -s /bin/bash -c "sudo apt-get update --quiet 2"
```


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
