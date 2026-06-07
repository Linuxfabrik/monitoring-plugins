# Check redfish-firmwareinventory


## Overview

Reports the firmware inventory of a Redfish-compatible server via the Redfish API. Lists every firmware component with its installed version and identification, and alerts whenever a component reports a degraded or failed health state.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/UpdateService/FirmwareInventory` to enumerate firmware components
* For each component, reads the name, installed version, manufacturer, release date and health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Lists every component, since this check doubles as a firmware version inventory


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-firmwareinventory> |
| Nagios/Icinga Check Name              | `check_redfish_firmwareinventory` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-firmwareinventory [-h] [-V] [--always-ok] [--brief]
                                 [--cache-expire CACHE_EXPIRE]
                                 [--ignore IGNORE] [--insecure]
                                 [--match MATCH] [--no-proxy]
                                 [--password PASSWORD] [--retries RETRIES]
                                 [--test TEST] [--timeout TIMEOUT] [--url URL]
                                 [--username USERNAME]

Reports the firmware inventory of a Redfish-compatible server via the Redfish
API. Lists every firmware component with its installed version and
identification, and alerts whenever a component reports a degraded or failed
health state.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --brief               Hide items that are OK and show only those in
                        WARN/CRIT state. Alerting is unaffected: all items
                        still drive the overall check state. Default: False
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
  --retries RETRIES     Number of extra attempts if a request to the Redfish
                        API fails, before the check gives up. Helps against an
                        occasionally slow or flaky management controller.
                        Default: 3
  --test TEST           For unit tests. Needs "path-to-stdout-file,path-to-
                        stderr-file,expected-retc".
  --timeout TIMEOUT     Network timeout in seconds. Default: 8 (seconds)
  --url URL             Redfish API URL. Default: https://localhost:5000
  --username USERNAME   Redfish API username.
```


## Usage Examples

```bash
./redfish-firmwareinventory --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked 3 firmware components.

Component                       ! Version          ! Manufacturer ! ReleaseDate          ! Updateable ! State
--------------------------------+------------------+--------------+----------------------+------------+------
Contoso BMC Firmware            ! 1.45.455b66-rev4 ! Contoso      ! 2017-08-22T12:00:00Z ! True       ! [OK]
Contoso Simple Storage Firmware ! 2.50             ! Contoso      ! 2021-10-18T12:00:00Z ! True       ! [OK]
Contoso BIOS Firmware           ! P79 v1.45        ! Contoso      ! 2017-12-06T12:00:00Z ! True       ! [OK]
```


## States

* OK if all firmware components report a healthy state (or report no health status at all).
* WARN if a firmware component health or health rollup state is "Warning".
* CRIT if a firmware component health or health rollup state is "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| firmware_components | Number | Number of firmware components checked. |
| firmware_components_not_ok | Number | Number of firmware components whose health is not OK. |


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including the `UpdateService/FirmwareInventory` collection) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-firmwareinventory/redfish-firmwareinventory --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-firmwareinventory/unit-test/stdout) were captured from this mockup server. Each scenario is one set of files named `<scenario>-firmwareinventory` (the collection) and `<scenario>-firmware-N` (one per component, in collection order); they are the raw Redfish responses the plugin walks. To simulate a fault, copy a healthy set and edit a component's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
