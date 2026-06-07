# Check redfish-managers


## Overview

Checks the health of all managers (BMCs such as iLO, iDRAC, or a generic BMC) of a Redfish-compatible server via the Redfish API. Reports every enabled manager with its identification (type, model, firmware version, power state, UUID) and rolled-up health status, and alerts whenever any manager's status leaves `OK`. Use `redfish-logservices` to inspect a manager's event log.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Managers` to enumerate manager members
* For each member, reads the manager type, model, firmware version, power state, UUID and rolled-up health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates managers in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-managers> |
| Nagios/Icinga Check Name              | `check_redfish_managers` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-managers [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                        [--password PASSWORD] [--test TEST]
                        [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Checks the health of all managers (BMCs such as iLO, iDRAC, or a generic BMC)
of a Redfish-compatible server via the Redfish API. Reports every enabled
manager with its identification (type, model, firmware version, power state,
UUID) and rolled-up health status, and alerts whenever any manager's status
leaves `OK`. Use `redfish-logservices` to inspect a manager's event log.

options:
  -h, --help           show this help message and exit
  -V, --version        show program's version number and exit
  --always-ok          Always returns OK.
  --insecure           This option explicitly allows insecure SSL connections.
  --no-proxy           Do not use a proxy.
  --password PASSWORD  Redfish API password.
  --test TEST          For unit tests. Needs "path-to-stdout-file,path-to-
                       stderr-file,expected-retc".
  --timeout TIMEOUT    Network timeout in seconds. Default: 8 (seconds)
  --url URL            Redfish API URL. Default: https://localhost:5000
  --username USERNAME  Redfish API username.
```


## Usage Examples

```bash
./redfish-managers --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked manager health on 1 member.

Manager: BMC Joo Janta 200, Firmware: 1.45.455b66-rev4, Power: On, UUID: 58893887-8974-2487-2389-841168418919
```


## States

* OK if all enabled managers report a healthy rolled-up state.
* WARN if a manager health or health rollup state is "Warning".
* CRIT if a manager health or health rollup state is "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| managers | Number | Number of enabled managers checked. |
| managers_not_ok | Number | Number of managers whose health is not OK. |


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including a `Managers` collection) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-managers/redfish-managers --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-managers/unit-test/stdout) were captured from this mockup server. Each scenario is one set of files named `<scenario>-managers` (the collection) and `<scenario>-manager` (the member); they are the raw Redfish responses the plugin walks. To simulate a fault, copy a healthy set and edit the manager's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
