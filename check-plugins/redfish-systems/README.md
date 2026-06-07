# Check redfish-systems


## Overview

Checks the overall system health reported by a Redfish-compatible server via the Redfish API. Reports every enabled system member with its identification (manufacturer, model, hostname, SKU, serial number), compute summary (processors, BIOS version, power state, indicator LED) and rolled-up health status, and alerts whenever any system's status leaves `OK`. Use `redfish-storage` for drive- and storage-controller-specific monitoring.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check usually completes within a few seconds, but a slow or retried request can take longer. The bundled Director basket allows a 60 second runtime timeout.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.
* This check reports system-level (rolled-up) health only. For dedicated component monitoring use `redfish-storage`, `redfish-memory`, `redfish-processors`, `redfish-ethernetinterfaces`, `redfish-sensors`, `redfish-managers` or `redfish-firmwareinventory`.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, reads the identification, compute summary and rolled-up health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates systems in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-systems> |
| Nagios/Icinga Check Name              | `check_redfish_systems` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-systems [-h] [-V] [--always-ok] [--cache-expire CACHE_EXPIRE]
                       [--insecure] [--no-proxy] [--password PASSWORD]
                       [--retries RETRIES] [--test TEST] [--timeout TIMEOUT]
                       [--url URL] [--username USERNAME]

Checks the overall system health reported by a Redfish-compatible server via
the Redfish API. Reports every enabled system member with its identification
(manufacturer, model, hostname, SKU, serial number), compute summary
(processors, BIOS version, power state, indicator LED) and rolled-up health
status, and alerts whenever any system's status leaves `OK`. Use `redfish-
storage` for drive- and storage-controller-specific monitoring.

options:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  --always-ok           Always returns OK.
  --cache-expire CACHE_EXPIRE
                        The amount of time after which the credential/data
                        cache expires, in minutes. Default: 15
  --insecure            This option explicitly allows insecure SSL
                        connections.
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
./redfish-systems --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked system health on 1 member.

Member: Contoso 3500, HostName: web483, Processors: 2x Multi-Core Intel(R) Xeon(R) processor 7xxx Series (16 logical), BIOS: P79 v1.45 (12/06/2017), Power: On, LED: Off, SKU: 8675309, SerNo: 437XR1138R2
```


## States

* OK if every enabled system reports a healthy rolled-up state.
* WARN if a system health or health rollup state is "Warning".
* CRIT if a system health or health rollup state is "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

This plugin does not provide any performance data.


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including a `Systems` collection) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-systems/redfish-systems --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-systems/unit-test/stdout) are the raw Redfish responses the plugin walks, one set per scenario named `<scenario>-systems` (the collection) and `<scenario>-system` (the member). To simulate a fault, copy a healthy set and edit the system's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
