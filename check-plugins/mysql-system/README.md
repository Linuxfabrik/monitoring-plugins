# Check mysql-system


## Overview

Checks Linux kernel parameters that affect MySQL/MariaDB stability and performance: `vm.swappiness`, the asynchronous-I/O event ceiling `fs.aio-max-nr`, the per-process file-handle ceiling `fs.nr_open`, and (on hosts that mount NFS) the sunrpc TCP slot-table size. Optionally also flags hosts that listen on too many TCP ports. Logic is taken from [MySQLTuner](https://github.com/major/MySQLTuner-perl):get_kernel_info() and has been verified in sync with MySQLTuner v2.8.41.

**Important Notes:**

* Must be running locally on the MySQL/MariaDB server to check the system requirements
* See [additional notes for all mysql monitoring plugins](https://linuxfabrik.github.io/monitoring-plugins/plugins-mysql/)
* Unlike MySQLTuner, this plugin does not check if all processes other than MySQL/MariaDB use more than 15% of total system memory. You may intentionally run a small DB on an application server, or the DB may not need 85% of available RAM.

**Data Collection:**

* Counts distinct local TCP ports in `LISTEN` state via `psutil` (if available). Connections in `ESTABLISHED`, `TIME_WAIT` etc. are not counted
* Reads Linux kernel parameters via `sysctl`
* Does not need access to MySQL/MariaDB itself


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/mysql-system> |
| Nagios/Icinga Check Name              | `check_mysql_system` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No |
| Requirements                          | Read access to `/proc/sys/*` (default for any user). No MySQL/MariaDB credentials needed - the plugin does not connect to the database |
| 3rd Party Python modules              | `psutil` |


## Help

```text
usage: mysql-system [-h] [-V] [--always-ok]
                    [--maxportsallowed MAXPORTSALLOWED]

Checks Linux kernel parameters that affect MySQL/MariaDB stability and
performance: vm.swappiness, the asynchronous-I/O event ceiling fs.aio-max-nr,
the per-process file-handle ceiling fs.nr_open, and (on hosts that mount NFS)
the sunrpc TCP slot-table size. Optionally also flags hosts that listen on too
many TCP ports. Alerts on misconfigured settings.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --maxportsallowed MAXPORTSALLOWED
                        Maximum number of TCP ports listening on this host. 0
                        disables the check. Default: 0
```


## Usage Examples

```bash
./mysql-system --maxportsallowed 15
```

Output:

```text
There are too many listening ports: 56 listening, 15 allowed (consider dedicating a server for your database installation with less services running on). vm.swappiness is 60, should be 10 or below (set `vm.swappiness=10` in /etc/sysctl.conf or /etc/sysctl.d/, then `sysctl -p`). sunrpc.tcp_slot_table_entries is 2, should be at least 128 (set `sunrpc.tcp_slot_table_entries=128` in /etc/sysctl.conf or /etc/sysctl.d/, then `sysctl -p`). fs.aio-max-nr is 1048576 (1.0M). fs.nr_open is 2147483584 (2.1G).
```

When the host is fully tuned, the OK output enumerates each verified setting. Large counters are also rendered with an SI suffix in parens:

```text
16 listening TCP ports. vm.swappiness is 5. sunrpc.tcp_slot_table_entries is 128. fs.aio-max-nr is 1048576 (1.0M). fs.nr_open is 1073741816 (1.1G).
```


## States

* OK if all kernel parameters are within the recommended range and the port count is acceptable.
* WARN if `--maxportsallowed` is set and the count of listening TCP ports exceeds it.
* WARN if `vm.swappiness > 10`.
* WARN if `sunrpc.tcp_slot_table_entries <= 100` (only on hosts where `/proc/sys/sunrpc` exists).
* WARN if `fs.aio-max-nr < 1M`.
* WARN if `fs.nr_open < 1M`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| mysql_kernel_fs_aio_max_nr | Number | Maximum number of asynchronous I/O operations the system can handle. |
| mysql_kernel_fs_nr_open | Number | Per-process ceiling for the number of open file descriptors. |
| mysql_kernel_sunrpc_tcp_slot_table_entries | Number | Number of TCP RPC entries pre-allocated for in-flight RPC requests. Only emitted when `/proc/sys/sunrpc` exists. |
| mysql_kernel_vm_swappiness | Percentage | Balance between swapping out runtime memory versus dropping pages from the system page cache. |
| mysql_listening_ports | Number | Count of distinct local TCP ports in `LISTEN` state. |


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
* Credits:

    * heavily inspired by MySQLTuner (<https://github.com/major/MySQLTuner-perl>)
