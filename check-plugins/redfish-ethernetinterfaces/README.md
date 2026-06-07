# Check redfish-ethernetinterfaces


## Overview

Checks the state of all Ethernet interfaces in a Redfish-compatible server via the Redfish API. Alerts when any enabled Ethernet interface reports a degraded or failed health state. The link status (up/down) is reported for information but does not by itself trigger an alert, because an unused interface being down is a normal condition. System-level health is deliberately ignored by this check; use `redfish-systems` for that.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, follows the `EthernetInterfaces` link and queries every interface for its MAC address, link status, speed and health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates systems and interfaces in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-ethernetinterfaces> |
| Nagios/Icinga Check Name              | `check_redfish_ethernetinterfaces` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-ethernetinterfaces [-h] [-V] [--always-ok]
                                  [--cache-expire CACHE_EXPIRE]
                                  [--ignore IGNORE] [--insecure]
                                  [--match MATCH] [--no-proxy]
                                  [--password PASSWORD] [--test TEST]
                                  [--timeout TIMEOUT] [--url URL]
                                  [--username USERNAME]

Checks the state of all Ethernet interfaces in a Redfish-compatible server via
the Redfish API. Alerts when any enabled Ethernet interface reports a degraded
or failed health state. The link status (up/down) is reported for information
but does not by itself trigger an alert, because an unused interface being
down is a normal condition. System-level health is deliberately ignored by
this check; use `redfish-systems` for that.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --ignore IGNORE       Ignore items whose name matches this Python regular
                        expression. Case-sensitive by default; use `(?i)` for
                        case-insensitive matching. Can be specified multiple
                        times.
  --insecure            This option explicitly allows insecure SSL
                        connections.
  --match MATCH         Only check items whose name matches this Python
                        regular expression. Case-sensitive by default; use
                        `(?i)` for case-insensitive matching. Can be specified
                        multiple times.
  --no-proxy            Do not use a proxy.
  --password PASSWORD   Redfish API password.
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Redfish API URL. Default: https://localhost:5000
  --username USERNAME   Redfish API username.
```


## Usage Examples

```bash
./redfish-ethernetinterfaces --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked Ethernet interfaces on 1 member.

Member: Contoso 3500, HostName: web483, SKU: 8675309, SerNo: 437XR1138R2

Interface    ! MAC               ! Speed Mbps ! Full Duplex ! Link   ! State
-------------+-------------------+------------+-------------+--------+------
12446A3B0411 ! 12:44:6A:3B:04:11 ! 1000       ! True        ! LinkUp ! [OK]
12446A3B8890 ! AA:BB:CC:DD:EE:00 ! 1000       ! True        ! LinkUp ! [OK]
VLAN1        ! 12:44:6A:3B:04:11 ! 1000       ! True        ! LinkUp ! [OK]
ToManager    ! AA:BB:CC:DD:EE:FE ! 100        ! True        !        ! [OK]
```


## States

* OK if all enabled Ethernet interfaces report a healthy state.
* WARN if an enabled interface health or health rollup state is "Warning".
* CRIT if an enabled interface health or health rollup state is "Critical".
* The link status is informational only and does not change the result.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| ethernet_interfaces | Number | Number of enabled Ethernet interfaces checked. |
| ethernet_interfaces_not_ok | Number | Number of Ethernet interfaces whose health is not OK. |


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including an `EthernetInterfaces` collection) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-ethernetinterfaces/redfish-ethernetinterfaces --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-ethernetinterfaces/unit-test/stdout) were captured from this mockup server. Each scenario is one set of files named `<scenario>-systems`, `<scenario>-system`, `<scenario>-ethernetinterfaces` and `<scenario>-nic-N` (one per interface, in collection order); they are the raw Redfish responses the plugin walks. To simulate a fault, copy a healthy set and edit an interface's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
