# Check redfish-storage


## Overview

Checks the state of all physical drives, volumes and their storage controllers in a Redfish-compatible server via the Redfish API. Alerts when any drive, volume or storage controller reports a degraded or failed state. System-level health (processors, BIOS, power, temperature, indicator LED, etc.) is deliberately ignored by this check so that a system warning unrelated to storage does not mask the storage status; use `redfish-systems` for that.

**Important Notes:**

* Tested on DELL iDRAC and DMTF Simulator
* A check usually completes within a few seconds, but a slow or retried request can take longer. The bundled Director basket allows a 60 second runtime timeout.
* This check runs with both HTTP and HTTPS. It uses GET requests only.
* No additional Python Redfish modules need to be installed.

**Data Collection:**

* Queries `/redfish/v1/Systems` to enumerate system members
* For each member, follows the `Storage` link and queries every storage controller, its physical drives and, where present, its volumes (logical drives) for health status
* Uses HTTP Basic authentication if `--username` and `--password` are provided
* Only evaluates systems, drives, volumes and storage controllers in "Enabled" or "Quiesced" state


## Fact Sheet

| Fact | Value |
|----|-----|
| Check Plugin Download                 | <https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-storage> |
| Nagios/Icinga Check Name              | `check_redfish_storage` |
| Check Interval Recommendation         | Every 5 minutes |
| Can be called without parameters      | Yes |
| Runs on                               | Cross-platform |
| Compiled for Windows                  | No |


## Help

```text
usage: redfish-storage [-h] [-V] [--always-ok] [--brief]
                       [--cache-expire CACHE_EXPIRE] [--ignore IGNORE]
                       [--insecure] [--inventory] [--match MATCH] [--no-proxy]
                       [--password PASSWORD] [--retries RETRIES] [--test TEST]
                       [--timeout TIMEOUT] [--url URL] [--username USERNAME]

Checks the state of all physical drives, volumes and their storage controllers
in a Redfish-compatible server via the Redfish API. Alerts when any drive,
volume or storage controller reports a degraded or failed state. System-level
health (processors, BIOS, power, temperature, indicator LED, etc.) is
deliberately ignored by this check so that a system warning unrelated to
storage does not mask the storage status; use `redfish-systems` for that.

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
  --inventory           Output the parsed components as JSON on stdout and
                        exit OK, instead of running a health check. Use this
                        to collect a hardware inventory: the JSON is a single
                        object keyed by component type, so the output of
                        several Redfish checks can be merged into one
                        inventory document with `jq --slurp`. Ignores --brief,
                        --match and --ignore. Default: False
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
./redfish-storage --url=https://bmc --username=redfish-monitoring --password='linuxfabrik'
```

Output:

```text
Everything is ok, checked storage on 1 member.

Member: Contoso 3500, HostName: web483, SKU: 8675309, SerNo: 437XR1138R2

Disk  ! Type ! Proto ! Manufacturer ! Model         ! SerialNumber ! Size     ! LifeLeft % ! State
------+------+-------+--------------+---------------+--------------+----------+------------+------
SSD 0 ! SSD  ! SATA  ! MICRON       ! MTFDDAV480TDS ! 202629662A88 ! 447.1GiB ! 100        ! [OK]
SSD 1 ! SSD  ! SATA  ! MICRON       ! MTFDDAV480TDS ! 202629662A78 ! 447.1GiB ! 100        ! [OK]

Volume         ! RAID  ! Size     ! Encrypted ! State
---------------+-------+----------+-----------+------
Virtual Disk 0 ! RAID1 ! 931.3GiB ! False     ! [OK]

ID        ! Name            ! Description     ! Drives ! State
----------+-----------------+-----------------+--------+------
RAID.SL.1 ! PERC H740P Mini ! PERC H740P Mini ! 2      ! [OK]
```


## States

* OK if all enabled drives, volumes and storage controllers report a healthy state.
* WARN if any of them reports a health or health rollup state of "Warning".
* CRIT if any of them reports a health or health rollup state of "Critical".
* System-level health is not considered. Use `redfish-systems` for that.
* `--always-ok` suppresses all alerts and always returns OK.


## Perfdata / Metrics

The per-drive metrics depend on your hardware: a drive is only reported when it exposes the corresponding value.

| Name | Type | Description |
|----|----|----|
| \<drive\>_media_life_left | Percentage | Predicted remaining life of a drive's media (0-100%). Example: `SSD_0_media_life_left` |
| \<drive\>_power_on_hours | Number | Hours a drive has been powered on. Example: `SSD_0_power_on_hours` |
| \<drive\>_temperature | Temperature | Drive temperature in degrees Celsius. Example: `SSD_0_temperature` |
| drives | Number | Number of enabled drives checked. |
| drives_not_ok | Number | Number of drives whose health is not OK. |
| storage_controllers | Number | Number of enabled storage controllers checked. |
| storage_controllers_not_ok | Number | Number of storage controllers whose health is not OK. |
| volumes | Number | Number of enabled volumes (logical drives) checked. |
| volumes_not_ok | Number | Number of volumes whose health is not OK. |


## For Maintainers

You don't need a physical server with a real BMC (the management controller that serves the Redfish API, e.g. HPE iLO or Dell iDRAC) to develop or test this plugin. The official DMTF Redfish mockup server serves a static, read-only Redfish tree over plain HTTP, which is exactly what this GET-only plugin needs. Note that the bundled `public-rackmount1` mockup ships no storage subsystem, so the offline fixtures are the primary way to exercise the drive and volume paths.

Run the mockup server and point the plugin at it, from the repository root:

```bash
podman run \
    --detach --rm \
    --name lfmp-redfish-mock \
    --publish 5000:8000 \
    docker.io/dmtf/redfish-mockup-server:latest
sleep 3
check-plugins/redfish-storage/redfish-storage --url=http://127.0.0.1:5000 --no-proxy
podman stop lfmp-redfish-mock
```

Use `http://127.0.0.1:5000` rather than `http://localhost:5000`, because `localhost` may resolve to IPv6 (`::1`) while the published container port is bound to IPv4.

The fixtures under [`unit-test/stdout/`](https://github.com/Linuxfabrik/monitoring-plugins/tree/main/check-plugins/redfish-storage/unit-test/stdout) are the raw Redfish responses the plugin walks, one set per scenario named `<scenario>-systems`, `<scenario>-system`, `<scenario>-storages`, `<scenario>-storage` and `<scenario>-drive-N`; when the Storage member advertises a Volumes link the set also contains `<scenario>-volumes` and `<scenario>-volume-N`. To simulate a fault, copy a healthy set and edit a drive's, volume's or controller's `Status.Health` to `Critical` or `Warning`. The offline test suite is run with `./run` from the `unit-test` directory.


## Credits, License

* Authors: [Linuxfabrik GmbH, Zurich](https://www.linuxfabrik.ch)
* License: The Unlicense, see [LICENSE file](https://unlicense.org/).
