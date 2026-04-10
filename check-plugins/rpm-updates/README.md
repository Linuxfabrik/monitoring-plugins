# Check rpm-updates


## Overview

Checks for available RPM package updates on RHEL, CentOS, Fedora, and compatible systems. Reports the number and type of available advisories (bugfix, enhancement, security). This check only lists updates and never actually installs anything.

**Important Notes:**

* The `--query` parameter accepts an SQL WHERE clause to filter the list of available updates. The following database columns can be used:
    * `arch` (TEXT)
    * `package` (TEXT)
    * `repo_installed` (TEXT)
    * `repo_upgrade` (TEXT)
    * `version_installed` (TEXT)
    * `version_upgrade` (TEXT)
* The "Type" column in the output lists the type of update for each intermediate version. Abbreviation meanings:
    * B: Bugfix
    * E: Enhancement
    * S: Security
    * U: Unspecified
    * no character: unknown

**Data Collection:**

* Executes `yum list --upgrades`, `yum list --installed`, and `yum updateinfo list --available`
* Stores all package and advisory information in a local SQLite database for SQL-based filtering via `--query`
* Plugin execution may take more than 10 seconds due to yum operations (default timeout: 120 seconds)

**Compatibility:**

* Linux


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-updates> |
| Nagios/Icinga Check Name              | `check_rpm_updates` |
| Check Interval Recommendation         | Once a day |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| Uses SQLite DBs                       | `$TEMP/linuxfabrik-monitoring-plugins-rpm-updates.db` |


## Help

```text
usage: rpm-updates [-h] [-V] [--always-ok] [--only-critical] [--query QUERY]
                   [--timeout TIMEOUT] [-w WARN]

Checks for available RPM package updates on RHEL, CentOS, Fedora, and
compatible systems. Reports the number and type of available advisories
(bugfix, enhancement, security). Alerts when updates are available. This check
only lists updates and never actually installs anything.

options:
  -h, --help          show this help message and exit
  -V, --version       show program's version number and exit
  --always-ok         Always returns OK.
  --only-critical     Only report security updates and upgrades.
  --query QUERY       SQL WHERE clause to filter the list of available
                      updates. Supports regular expressions via a REGEXP
                      statement. See the README for a list of available
                      columns. If specified, a list of matching updates is
                      printed. Example: `--query='package like "bind9-%"'`.
                      Default: 1
  --timeout TIMEOUT   Network timeout in seconds. Default: 120 (seconds)
  -w, --warning WARN  Minimum number of available updates to return WARNING.
                      Default: 1
```


## Usage Examples

```bash
./rpm-updates --only-critical --query='package in ("audit", "bind-utils", "gcc-c++")'
```

Output:

```text
30 updates available. [WARNING]

Package    ! Installed     ! Upgrade to           ! Type 
-----------+---------------+----------------------+------
audit      ! 3.0.7-5       ! 3.1.2-1              ! B    
bind-utils ! 32:9.11.36-11 ! 32:9.11.36-16.el8_10 !      
gcc-c++    ! 8.5.0-20      ! 8.5.0-26             ! BSB  
```


## States

* OK if the number of available updates is below `--warning`.
* WARN if the number of updatable packages meets or exceeds `--warning` (default: 1).
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| updates | Number | Number of updatable packages matching the current `--query`. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
