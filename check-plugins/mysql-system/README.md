# Check mysql-system

## Overview

Checks system requirements and kernel settings specifically for MySQL/MariaDB, including swap configuration, open file limits, and other OS-level parameters that affect database performance and stability. Logic is taken from [MySQLTuner script](https://github.com/major/MySQLTuner-perl):get_kernel_info(), v1.9.8.

**Alerting Logic:**

* WARN if there are too many listening ports (only checked when `--maxportsallowed` is set to a value greater than 0)
* WARN if `vm.swappiness` is greater than 10
* WARN if `sunrpc.tcp_slot_table_entries` is 100 or less (only if `/proc/sys/sunrpc` exists)
* WARN if `fs.aio-max-nr` is less than 1,000,000 (only if `/proc/sys/fs/aio-max-nr` exists)

**Data Collection:**

* Counts open ports using `psutil` (if available)
* Reads Linux kernel parameters via `sysctl`
* Does not need access to MySQL/MariaDB itself

**Compatibility:**

* Must be running locally on the MySQL/MariaDB server to check the system requirements
* On Windows there are no kernel settings that can be checked

**Important Notes:**

* See [additional notes for all mysql monitoring plugins](https://github.com/Linuxfabrik/monitoring-plugins/blob/main/PLUGINS-MYSQL.md)
* Unlike MySQLTuner, this plugin does not check if all processes other than MySQL/MariaDB use more than 15% of total system memory. You may intentionally run a small DB on an application server, or the DB may not need 85% of available RAM.


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-system> |
| Nagios/Icinga Check Name              | `check_mysql_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: mysql-system [-h] [-V] [--always-ok]
                    [--maxportsallowed MAXPORTSALLOWED]

Checks system requirements and kernel settings for MySQL/MariaDB, including
swap configuration, open file limits, and other OS-level parameters that
affect database performance and stability. Alerts on misconfigured system
settings.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --maxportsallowed MAXPORTSALLOWED
                        Maximum number of open ports allowed on this host. 0
                        disables the check. Default: 0
```


## Usage Examples

```bash
./mysql-system --maxportsallowed 15
```

Output:

```text
There are too many listening ports: 56 opened > 15 allowed (consider dedicating a server for your database installation with less services running on). vm.swappiness is 60, should be <= 10 (use `echo 10 > /proc/sys/vm/swappiness`). sunrpc.tcp_slot_table_entries is 2, should be > 100 (use `echo 128 > /proc/sys/sunrpc/tcp_slot_table_entries`).
```


## States

* OK if all kernel parameters are within the recommended range and the port count is acceptable.
* WARN if there are too many listening ports.
* WARN if any of the checked Linux kernel parameters is not in the optimal range.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_kernel_fs.aio-max-nr | Number | Maximum number of asynchronous I/O operations the system can handle. |
| mysql_kernel_sunrpc.tcp_slot_table_entries | Number | Number of TCP RPC entries pre-allocated for in-flight RPC requests. |
| mysql_kernel_vm.swappiness | Percentage | Balance between swapping out runtime memory versus dropping pages from the system page cache. |
| mysql_opened_ports | Number | Number of opened ports. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
