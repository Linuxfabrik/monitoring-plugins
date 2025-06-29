# Check openvpn-client-list

## Overview

Prints a list of all clients connected to the OpenVPN Server, and optionally checks their number against thresholds. Fetches the info from `/var/log/openvpn-status.log` (default), which you configure on your OpenVPN appliance using `status /var/log/openvpn-status.log`. Needs sudo.


## Fact Sheet

| Fact | Value |
|----|----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/openvpn-client-list> |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Compiled for Windows                  | No |


## Help

```text
usage: openvpn-client-list [-h] [-V] [-c CRIT] [--filename FILENAME]
                           [--test TEST] [-w WARN]

Prints a list of all clients connected to the OpenVPN Server

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  -c, --critical CRIT  Set the critical threshold for the number of connected
                       clients. Default: None
  --filename FILENAME  Set the path of the log filename. Default:
                       /var/log/openvpn-status.log
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  -w, --warning WARN   Set the warning threshold for the number of connected
                       clients. Default: None
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

* WARN or CRIT if number of connected users is above a given threshold.


## Perfdata / Metrics

* Number of clients connected.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
