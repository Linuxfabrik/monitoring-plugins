# Check redfish-memory


## Overview

Checks the state of all memory modules (DIMMs) in a Redfish-compatible server via the Redfish API. Alerts when any memory module reports a degraded or failed state. System-level health (processors, storage, power, temperature, indicator LED, etc.) is deliberately ignored by this check so that a system warning unrelated to memory does not mask the module status; use `redfish-systems` for that.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, follows the `Memory` link and queries every memory module for its capacity, type, speed, identification and health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates systems and memory modules in "Enabled" or "Quiesced" state, so absent or disabled slots are skipped


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-memory> |
| Nagios/Icinga Check Name              | `check_redfish_memory` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-memory [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                      [--password PASSWORD] [--test TEST] [--timeout TIMEOUT]
                      [--url URL] [--username USERNAME]

Checks the state of all memory modules (DIMMs) in a Redfish-compatible server
via the Redfish API. Alerts when any memory module reports a degraded or
failed state. System-level health (processors, storage, power, temperature,
indicator LED, etc.) is deliberately ignored by this check so that a system
warning unrelated to memory does not mask the module status; use `redfish-
systems` for that.

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
./redfish-memory --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked memory on 1 member.

Member: Contoso 3500, HostName: web483, SKU: 8675309, SerNo: 437XR1138R2

Module      ! Slot   ! Type ! Size    ! Speed MHz ! Manufacturer ! SerialNumber ! State
------------+--------+------+---------+-----------+--------------+--------------+------
DIMM Slot 1 ! DIMM 1 ! DDR4 ! 32.0GiB !           !              !              ! [OK]
DIMM Slot 2 ! DIMM 2 ! DDR4 ! 32.0GiB !           !              !              ! [OK]
DIMM Slot 3 ! DIMM 3 ! DDR4 ! 32.0GiB !           !              !              ! [OK]
```


## States

* OK if all enabled memory modules report a healthy state.
* WARN if an enabled memory module health or health rollup state is "Warning".
* CRIT if an enabled memory module health or health rollup state is "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

| Name | Type | Description |
|----|----|----|
| memory_modules | Number | Number of enabled memory modules checked. |
| memory_modules_not_ok | Number | Number of memory modules whose health is not OK. |


## For Maintainers

There is no need for a real BMC to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including a `Memory` collection with several DIMMs) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-memory/redfish-memory --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-memory/unit-test/stdout) were captured from this mockup server. Each scenario is one set of files named `<scenario>-systems`, `<scenario>-system`, `<scenario>-memory` and `<scenario>-dimm-N` (one per memory module, in collection order); they are the raw Redfish responses the plugin walks. To simulate a fault, copy a healthy set and edit a module's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
