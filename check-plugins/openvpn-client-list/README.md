# Check openvpn-client-list


## Overview

Lists all clients currently connected to an OpenVPN server by parsing the status log file in any of the formats OpenVPN writes (`status-version` 1, 2 or 3). Reports client name, external and internal address, and connection time. Alerts when the number of connected clients is outside the `--warning` or `--critical` range; without thresholds the check only lists the clients. Requires root or sudo.

**Important Notes:**

* Requires root or sudo to read the OpenVPN status log file.
* `--filename` is confined to `/var/log`. The check runs as root via sudo, so it refuses a path that resolves outside the system log directory, which stops it from being turned into an arbitrary root file read. To read a status file stored elsewhere, bind-mount that location under `/var/log` (a symlink is rejected); see the [Troubleshooting section](https://github.com/Linuxfabrik/monitoring-plugins#troubleshooting).

**Data Collection:**

* Reads the OpenVPN status log file (default: `/var/log/openvpn-status.log`)
* Detects the format by its content: `status-version 1` (client list and routing table), `2` (comma-separated, the default of the `openvpn-server@.service` unit) and `3` (tab-separated). In formats 2 and 3, the columns are found by their names in the `HEADER` line.
* Extracts client name, external IP, internal IP and connection time. The external IP is shown without the protocol prefix OpenVPN 2.7 adds (`udp4:`, `tcp4-server:`) and without the port, IPv4 and IPv6 alike.
* An empty file counts as zero connected clients, since OpenVPN truncates the file before it rewrites it.
* The status log file must be configured on the OpenVPN server using `status /var/log/openvpn-status.log`


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openvpn-client-list> |
| Nagios/Icinga Check Name              | `check_openvpn_client_list` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Linux |
| Compiled for Windows                  | No (runs with Python interpreter) |
| Requirements                          | User with higher permissions |


## Help

```text
usage: openvpn-client-list [-h] [-V] [--always-ok] [-c CRIT]
                           [--filename FILENAME] [--no-perfdata] [-w WARN]

Lists all clients currently connected to an OpenVPN server by parsing the
status log file in any of the formats OpenVPN writes (`status-version` 1, 2 or
3). Reports client name, external and internal address, and connection time.
Alerts when the number of connected clients is outside the `--warning` or
`--critical` range; without thresholds the check only lists the clients.
Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  -c, --critical CRIT  CRIT threshold for the number of connected clients.
                       Supports Nagios ranges. Default: None
  --filename FILENAME  Path to the OpenVPN status log file. Default:
                       /var/log/openvpn-status.log
  --no-perfdata        Suppress the performance data section from the output.
                       The status message and the exit code are unaffected, so
                       alerting keeps working while trending data is dropped.
  -w, --warning WARN   WARN threshold for the number of connected clients.
                       Supports Nagios ranges. Default: None

Documentation:
https://linuxfabrik.github.io/monitoring-plugins/check-plugins/openvpn-client-list/
```


## Usage Examples

```bash
./openvpn-client-list --warning=20 --critical=100 --filename=/var/log/openvpn-status.log
```

Output:

```text
5 users connected to OpenVPN Server.

Common Name          ! External IP  ! Internal IP ! Connected since
---------------------+--------------+-------------+-------------------------
user1@linuxfabrik.ch ! 192.0.2.1    ! 10.8.0.135  ! Tue Jan  1 12:56:08 2020
user2@linuxfabrik.ch ! 192.0.2.2    ! 10.8.0.6    ! Tue Jan  1 09:56:59 2020
user3@linuxfabrik.ch ! 198.51.100.3 ! 10.8.0.2    ! Tue Jan  1 08:34:21 2020
user4@linuxfabrik.ch ! 203.0.113.4  ! 10.8.0.3    ! Tue Jan  1 08:38:10 2020
user4@linuxfabrik.ch ! 203.0.113.4  ! 10.8.0.4    ! Tue Jan  1 08:38:20 2020
```


## States

* OK if the number of connected clients is inside the thresholds, or if no thresholds are given.
* OK with "0 users connected" on an empty status file, since OpenVPN truncates the file before it rewrites it.
* WARN if the number of connected clients is outside the `--warning` range.
* CRIT if the number of connected clients is outside the `--critical` range.
* UNKNOWN if the file is not an OpenVPN status file, cannot be read, or resolves outside `/var/log`.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| clients | Number | Number of clients currently connected to the OpenVPN server. |


## Troubleshooting

### `Unknown status file format.`

The file named by `--filename` is not an OpenVPN status file. Check the `status` line in the OpenVPN server configuration and point `--filename` at the file it names.

### Status log file cannot be read

`I/O error "No such file or directory" while opening or reading /var/log/openvpn-status.log`

The status log file does not exist or is not readable. Verify that the OpenVPN server is configured with `status /var/log/openvpn-status.log` and that the check has sufficient permissions (root or sudo).


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
