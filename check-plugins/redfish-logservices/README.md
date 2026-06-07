# Check redfish-logservices


## Overview

Checks the event log entries exposed under the LogServices of a Redfish-compatible server (the System Event Log, SEL) via the Redfish API. Alerts based on the severity of the log entries.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check takes up to 10 seconds. Increasing runtime timeout to 30 seconds is recommended.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Reads the service root to detect the vendor, then queries the `Managers` collection (or `Systems` on Supermicro) to locate the log service
* Reads the SEL log entries and evaluates each entry's severity
* Uses HTTP Basic authentication if `--username` and `--password` are provided


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-logservices> |
| Nagios/Icinga Check Name              | `check_redfish_logservices` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-logservices [-h] [-V] [--always-ok] [--insecure] [--no-proxy]
                           [--password PASSWORD] [--test TEST]
                           [--timeout TIMEOUT] [--url URL]
                           [--username USERNAME]

Checks the event log entries exposed under the LogServices of a Redfish-
compatible server (the System Event Log, SEL) via the Redfish API. Alerts
based on the severity of the log entries.

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
./redfish-logservices --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Checked SEL on 1 member. There are critical errors.

/redfish/v1/Managers/BMC
* 2012-03-07T14:44:00Z: System May be Melting [CRITICAL]
```


## States

* OK if no log entry has a severity above OK.
* WARN if a log entry has severity "Warning".
* CRIT if a log entry has severity "Critical".
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

This plugin does not provide any performance data.


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree (including the manager log service) over plain HTTP, which is exactly what this GET-only plugin needs.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-logservices/redfish-logservices --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-logservices/unit-test/stdout) are the raw Redfish responses the plugin walks, one set per scenario named `<scenario>-root` (the service root), `<scenario>-managers` (the Managers collection) and `<scenario>-sel` (the log entries). To simulate an alert, copy a healthy set and add an entry with a `Severity` of `Critical` or `Warning` to the `-sel` file. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
