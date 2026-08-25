# Check rpm-updates


## Overview

Checks for available RPM package updates on RHEL, CentOS, Fedora, and compatible systems. Reports the number and type of available advisories (bugfix, enhancement, security). Alerts when the number of pending updates reaches the warning threshold, and when the number of security updates reaches the critical threshold. This check only lists updates and never actually installs anything.

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
* Stores all package and advisory information in a local SQLite database that lives only for the duration of the run, for SQL-based filtering via `--query`
* Counts an update as security-critical when it carries a security advisory (`S` in the "Type" column). Optionally narrows the report down to those updates (`--only-critical`); the security count is reported either way
* Plugin execution may take more than 10 seconds due to yum operations (default timeout: 120 seconds)


## Fact Sheet

| Fact | Value |
|----|---|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/rpm-updates> |
| Nagios/Icinga Check Name              | `check_rpm_updates` |
| Check Interval Recommendation         | Every day |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |


## Help

```text
usage: rpm-updates [-h] [-V] [--always-ok] [-c CRIT] [--no-perfdata]
                   [--only-critical] [--query QUERY] [--timeout TIMEOUT]
                   [-w WARN]

Checks for available RPM package updates on RHEL, CentOS, Fedora, and
compatible systems. Reports the number and type of available advisories
(bugfix, enhancement, security). Alerts when the number of pending updates
reaches the warning threshold, and when the number of security updates reaches
the critical threshold. This check only lists updates and never actually
installs anything.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  Minimum number of pending security updates to trigger a
                       CRITICAL. Counts the updates carrying a security
                       advisory, within the scope of `--query`. Unset by
                       default, so security updates raise a WARNING like any
                       other update until a threshold is given. Example:
                       `--critical=1` Default: None
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  --only-critical      Only report security updates and upgrades.
  --query QUERY        SQL WHERE clause to filter the list of available
                       updates. Supports regular expressions via a REGEXP
                       statement. See the README for a list of available
                       columns. If specified, a list of matching updates is
                       printed. Example: `--query='package like "bind9-%"'`.
                       Default: 1
  --timeout TIMEOUT    Network timeout in seconds. Default: 120 (seconds)
  -w, --warning WARN   Minimum number of pending updates to trigger a WARNING.
                       Default: 1

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/rpm-updates/
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

Wake somebody up as soon as an update carrying a security advisory is pending:

```bash
./rpm-updates --critical=1
```

Output:

```text
2 updates available, 2 of them critical. [CRITICAL]

Package     ! Installed   ! Upgrade to  ! Type
------------+-------------+-------------+-----
vim-data    ! 2:9.2.240-1 ! 2:9.2.280-1 ! S
vim-minimal ! 2:9.2.240-1 ! 2:9.2.280-1 ! S
```


## States

* OK if no updates are available (or both counts stay below their thresholds).
* WARN if the number of pending updates is >= `--warning` (default: 1).
* CRIT if the number of security updates is >= `--critical`. Unset by default, so security updates raise a WARNING like any other update until a threshold is given.
* UNKNOWN if one of the `yum` calls fails.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| critical_updates | Number | Number of updates carrying a security advisory, matching the current `--query`. |
| updates | Number | Number of updatable packages matching the current `--query`. With `--only-critical` this is the security count. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
