# Check openvpn-client-list

## Overview

Lists all clients currently connected to an OpenVPN server by parsing the status log file. Reports client name, remote address, bytes received and sent, and connection time. Optionally checks the number of connected clients against thresholds.

**Data Collection:**

* Reads the OpenVPN status log file (default: `/var/log/openvpn-status.log`)
* Parses `CLIENT_LIST` entries to extract client name, external IP, internal IP, and connection time
* The status log file must be configured on the OpenVPN server using `status /var/log/openvpn-status.log`

**Alerting Logic:**

* WARN or CRIT if the number of connected clients exceeds the configured thresholds

**Important Notes:**

* Requires root or sudo to read the OpenVPN status log file.


## Fact Sheet

| Fact | Value |
|----|----| 
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openvpn-client-list> |
| Nagios/Icinga Check Name              | `check_openvpn_client_list` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: openvpn-client-list [-h] [-V] [-c CRIT] [--filename FILENAME]
                           [--test TEST] [-w WARN]

Lists all clients currently connected to an OpenVPN server by parsing the
status log file. Reports client name, remote address, bytes received and sent,
and connection time. Requires root or sudo.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  CRIT threshold for the number of connected clients.
                       Default: None
  --filename FILENAME  Path to the OpenVPN status log file. Default:
                       /var/log/openvpn-status.log
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   WARN threshold for the number of connected clients.
                       Default: None
```


## Usage Examples

```bash
./openvpn-client-list --warning 20 --critical 100 --filename /var/log/openvpn-status.log
```

Output:

```text
5 users connected to OpenVPN Server.

Common Name      External IP  Internal    IP Connected since
-----------      -----------  ----------- ------------------
a@linuxfabrik.ch 1.2.3.4      10.123.11.4 Mon Jun  7 07:59:53 2021 
b@linuxfabrik.ch 2.3.4.5      10.123.11.5 Mon Jun  7 08:05:56 2021 
c@linuxfabrik.ch 3.4.5.6      10.123.11.3 Mon May 31 23:08:47 2021 
d@linuxfabrik.ch 4.5.6.7      10.123.11.6 Mon Jun  7 09:29:07 2021 
e@linuxfabrik.ch 5.6.7.8      10.123.11.2 Mon May 31 23:08:38 2021
```


## States

* OK if the number of connected clients is below the thresholds.
* WARN if the number of connected clients is >= `--warning`.
* CRIT if the number of connected clients is >= `--critical`.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| clients | Number | Number of clients currently connected to the OpenVPN server. |


## Troubleshooting

`Failed to read file /var/log/openvpn-status.log.`  
The status log file does not exist or is not readable. Verify that the OpenVPN server is configured with `status /var/log/openvpn-status.log` and that the check has sufficient permissions (root or sudo).


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
